# pub-dartlang-dart

The https://pub.dartlang.org site.

Implemented in Dart as a Managed VM AppEngine application.

## Running tests

The tests have been tested on Linux and Mac.

```
pub-dartlang-dart/ $ cd app
pub-dartlang-dart/app $ pub get
pub-dartlang-dart/app $ pub global activate test_runner
pub-dartlang-dart/app $ pub global run test_runner
```

## Testing locally without `gcloud preview app run`
For local development, running the application directly instead of through
`gcloud preview app run`, is typically most convenient. To do this use the
`main` entry point in `app/bin/server_io.dart`. To change the application
configuration look in this file for the instantiation of
`Configuration` objects, e.g.

```dart
final devConfiguration = new Configuration.dev_io(<project-id>, <bucket>);
```

This will use the Cloud Datastore associated with the project
`<project-id>` and the Cloud Storage bucket names `<bucket-name>`.

Running like this also requires a key for a Service Account for the project
`<project-id>`. The location of that key is also configured in the
`Configuration` object. The default is a file named `key.json` in the root
of the project.

## Testing locally with `gcloud preview app run`
Run the application with the local development server.

```
$ gcloud preview app run app.yaml
```

This will use the `main` entry point in `app/bin/server.dart`.

This will use the Cloud Datastore provided by the emulation provided by the
local API server. The application cannot run on an empty datastore, a few
configuration objects are required.

Check the Docker logs if the application crashes.

```
$ docker logs <container-id>
```

## Deploying a new version to production
Before deploying make sure that the default production configuration is still
active in `app/bin/server.dart`.

To deploy a new version to production use `gcloud preview app deploy`
passing the project name `dartlang-pub` - if that project is not already set
as the default project.

```
$ gcloud preview app --project dartlang-pub deploy --no-promote app.yaml
```

This will deploy a new version with a unique version name generated by
`gcloud preview app deploy`.

After deploying to gcloud, and getting a version name (like '20160330t124551')
from that deploy command, tag the deployed commit in the git repo with that
name:

```
git tag <version>
git push --tags
```

## Deploying a new version to staging
To deploy a new version to staging use `gcloud preview app deploy`, _but_
specify a version as well. This version must include the string `staging` to
make the deployment run on staging data.

```console
$ gcloud preview app --project dartlang-pub deploy app.yaml \
  --no-promote --version staging-my-test
```
