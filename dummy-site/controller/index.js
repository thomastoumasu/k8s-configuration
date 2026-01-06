import * as k8s from '@kubernetes/client-node';
import mustache from 'mustache';
import fs from 'fs';

// environment variable probably not needed: loadFromDefault() seems to work outside as well as inside cluster
const kc = new k8s.KubeConfig();
console.log(`dummysite controller started, NODE_ENV is ${process.env.NODE_ENV}`);
process.env.NODE_ENV === 'development' ? kc.loadFromDefault() : kc.loadFromCluster();

// Create api clients for deployments and pvc
const appsV1apiClient = kc.makeApiClient(k8s.AppsV1Api);
const coreV1apiClient = kc.makeApiClient(k8s.CoreV1Api);
// can also do: const client_pvc = k8s.KubernetesObjectApi.makeApiClient(kc);
// with: client_pvc.create(k8s.loadYaml(pvc_yaml)); and: client_pvc.delete(k8s.loadYaml(pvc_yaml));

// Create watch object (replaces the streams in k8s-material-example/app10)
const watch = new k8s.Watch(kc);
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

const fieldsFromDummysite = object => ({
  deployment_name: `dummysite-${object.metadata.name}-dep`,
  pvc_name: `dummysite-${object.metadata.name}-pvc`,
  site_name: object.metadata.name,
  namespace: object.metadata.namespace,
  website_url: object.spec.website_url,
});

const getFile = async file =>
  new Promise(res => {
    fs.readFile(file, 'utf-8', (err, buffer) => {
      if (err) {
        console.log('FAILED TO READ FILE', '----------------', err);
        return res(false);
      }
      return res(buffer);
    });
  });

const getYAML = async (file, fields) => {
  const yamlTemplate = await getFile(file);
  return mustache.render(yamlTemplate, fields);
};

const pvcAlreadyExists = async fields => {
  const { items } = await coreV1apiClient.listNamespacedPersistentVolumeClaim({
    namespace: fields.namespace,
  });
  return items.find(item => item.metadata.name === fields.pvc_name);
};

const deploymentAlreadyExists = async fields => {
  const { items } = await appsV1apiClient.listNamespacedDeployment({
    namespace: fields.namespace,
  });
  return items.find(item => item.metadata.name === fields.deployment_name);
};

const createResource = async fields => {
  console.log(
    '  Creating dummysite',
    fields.site_name,
    fields.website_url,
    'to ns',
    fields.namespace
  );
  try {
    if (!(await pvcAlreadyExists(fields))) {
      const pvc_yaml = await getYAML('pvc.mustache', fields);
      // console.log('pvc yaml to be sent to the API: ', pvc_yaml);
      await coreV1apiClient.createNamespacedPersistentVolumeClaim({
        namespace: fields.namespace,
        body: k8s.loadYaml(pvc_yaml),
      });
    } else {
      console.log(
        `a pvc for this resource already exists ('${fields.pvc_name}') - skipping pvc creation.`
      );
    }
    if (!(await deploymentAlreadyExists(fields))) {
      const dep_yaml = await getYAML('dep.mustache', fields);
      // console.log('deployment yaml to be sent to the API: ', dep_yaml);
      const createdDeployment = await appsV1apiClient.createNamespacedDeployment({
        namespace: fields.namespace,
        body: k8s.loadYaml(dep_yaml),
      });
      // console.log('Created deployment:', createdDeployment);
    } else {
      console.log(
        `a deployment for this resource already exists ('${fields.deployment_name}') - skipping deployment creation.`
      );
    }
  } catch (err) {
    console.log('error in creating dummysite');
    console.error(err);
  }
};

const updateResource = async fields => {
  console.log(
    '  Updating dummysite',
    fields.site_name,
    fields.website_url,
    'in ns',
    fields.namespace
  );
  try {
    const dep_yaml = await getYAML('dep.mustache', fields);
    // console.log('deployment yaml to be sent to the API: ', dep_yaml);
    const updatedDeployment = await appsV1apiClient.replaceNamespacedDeployment({
      namespace: fields.namespace,
      name: fields.deployment_name,
      body: k8s.loadYaml(dep_yaml),
    });
    // console.log('Updated deployment:', updatedDeployment);
  } catch (err) {
    console.log('error in updating dummysite');
    console.error(err);
  }
};

const deleteResource = async fields => {
  console.log(
    '  Deleting dummysite',
    fields.site_name,
    fields.website_url,
    'in ns',
    fields.namespace
  );
  try {
    await appsV1apiClient.deleteNamespacedDeployment({
      namespace: fields.namespace,
      name: fields.deployment_name,
    });
    await coreV1apiClient.deleteNamespacedPersistentVolumeClaim({
      namespace: fields.namespace,
      name: fields.pvc_name,
    });
  } catch (err) {
    console.log('error in deleting dummysite');
    console.error(err);
  }
};

const main = async () => {
  try {
    console.log('starting dummysites watcher');
    const req = await watch.watch(
      '/apis/stable.dwk/v1/dummysites',
      {},
      async (type, apiObj, watchObj) => {
        if (type === 'ADDED') {
          console.log('watcher - object added:', apiObj.metadata.name);
          const fields = fieldsFromDummysite(apiObj);
          await createResource(fields);
        } else if (type === 'MODIFIED') {
          console.log('watcher - object modified:', apiObj.metadata.name);
          const fields = fieldsFromDummysite(apiObj);
          await updateResource(fields);
        } else if (type === 'DELETED') {
          console.log('watcher - object deleted:', apiObj.metadata.name);
          const fields = fieldsFromDummysite(apiObj);
          await deleteResource(fields);
        } else {
          console.log('watcher - unknown action. TYPE was: ' + type);
        }
        // console.log(apiObj);
      },
      // done callback is called if the watch terminates normally
      err => console.error(err)
    );
    await delay(3600000);
    // watch returns a request object which you can use to abort the watch.
    req.abort();
  } catch (err) {
    console.error(err);
  }
};

main();
