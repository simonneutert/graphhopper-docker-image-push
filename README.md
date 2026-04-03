# Graphhopper Container Image Provider Repository

This repository holds the very basic things in order to make sure there's an updated graphhopper docker image which we use in our production server.

Kudos to [@israelhikingmap](https://github.com/israelhikingmap) for having done the heavy lifting and in being the proper source of the container image and maintaining it. ❤️

Images can be found on the GitHub Container Registry:  
https://ghcr.io/simonneutert/graphhopper  
See the [docker-compose.example.yml](./docker-compose.example.yml) for one way of how to run the image.

---

We would like to first and foremost thank the [graphhopper](https://www.graphhopper.com/) team for their hard work and amazing product!\
They are doing a great job and we are truly happy to help by contributing to their code base like we had done in the past.\
Graphhopper team has decided not to build a docker image and this repository is here to bridge that gap.

This repository is extremely simple.\
All it does is the following:

1. Every Sunday at 1 AM UTC it builds the latest code using GitHub Actions from the [graphhopper repository](https://github.com/graphhopper/graphhopper) and publishes the image to the GitHub Container Registry (GHCR)
2. It checks for new GraphHopper version tags and, if found, builds and publishes images with the corresponding tag
3. Adds a `graphhopper.sh` helper script for running the image

That's all.

## Quick start

The [config-example.yml](./config-example.yml) was copied from the graphhopper repository and can be used as a template for running the image.\
In case this needs to be updated, please open an issue, I will be happy to update it. ✌️

For a quick startup you can run the following command to create the Andorra routing:
```
docker run -p 8989:8989 ghcr.io/simonneutert/graphhopper:latest --url https://download.geofabrik.de/europe/andorra-latest.osm.pbf --host 0.0.0.0
```

Then visit your browser at `http://localhost:8989/`

You can also completely override the entry point and use this for example:

```
docker run --entrypoint /bin/bash ghcr.io/simonneutert/graphhopper:latest -c "wget https://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf -O /data/berlin.osm.pbf && java -Ddw.graphhopper.datareader.file=/data/berlin.osm.pbf -Ddw.graphhopper.graph.location=berlin-gh -jar *.jar server config-example.yml"
```

Check out `graphhopper.sh` for more usage options such as import.

### Change the JAVA_OPTS

The Dockerfile sets some default `JAVA_OPTS` for the Java runtime:

- `-Xmx1g` to set the maximum heap size to 1 GB
- `-Xms1g` to set the initial heap size to 1 GB

**But** you can override or add to these by setting the `JAVA_OPTS` environment variable when running the container.

**You are advised to set both `-Xmx` and `-Xms`**. Not setting both may result in the defaults being used for the one you don't set.

To set the `JAVA_OPTS` environment variable to pass additional options to the Java runtime. For example, to set the maximum heap size to 4 GB, you can run:

```
docker run -p 8989:8989 \
    -e JAVA_OPTS="-Xmx4g -Xms4g" \
    ghcr.io/simonneutert/graphhopper:latest \
        --url https://download.geofabrik.de/europe/andorra-latest.osm.pbf \
        --host 0.0.0.0
```

## CI / Publishing

- **Where:** [.github/workflows/build-and-publish.yml](.github/workflows/build-and-publish.yml).
- **Registry:** Images are pushed to `ghcr.io/<owner>/graphhopper` (owner defaults to `simonneutert`).
- **Auth:** The workflow uses the repository `GITHUB_TOKEN` and requires `packages: write` permission (configured in the workflow). No extra secrets are required for the default setup.

## Local development

- `prepare-local-build.sh` is provided as a convenience to prepare a local build context: it clones/updates the `graphhopper` repo, optionally checks out a tag, and ensures a Buildx builder is available. Usage:

```
./prepare-local-build.sh            # prepare master (suggested local tag: 'local')
./prepare-local-build.sh 7.0        # prepare specific tag/commit
```

- After running `prepare-local-build.sh` you can build locally with Buildx:

```
docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/<owner>/graphhopper:<tag> .
```

- To push from your machine to GHCR you can login and push manually:

```
echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin
docker push ghcr.io/<owner>/graphhopper:<tag>
```

## Supported architectures

- `amd64`
- `arm64`

## Contributing

Feel free to submit issues or pull requests if you would like to improve the code here
