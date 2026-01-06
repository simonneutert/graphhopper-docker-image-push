# Graphhopper docker provider repository

This repository holds the very basic things in order to make sure there's an updated graphhopper docker image which we use in our production server.

Images can be found on the GitHub Container Registry:  
https://ghcr.io/simonneutert/graphhopper

I would like to first and foremost thank the [graphhopper](https://www.graphhopper.com/) team for their hard work and amazing product! 
They are doing a great job and we are truly happy to help by contributing to their code base like we had done in the past.
Graphhopper team has decided not to build a docker image and this repository is here to bridge that gap.

This repository is extremely simple (says [Israel Hiking Map](https://github.com/IsraelHikingMap) in their [README](https://github.com/IsraelHikingMap/graphhopper-docker-image-push/blob/main/README.md)), yet this fork would never been made without the amazing work of [Israel Hiking Map](https://github.com/IsraelHikingMap) for open sourcing their [docker build setup](https://github.com/IsraelHikingMap/graphhopper-docker-image-push).  
> Thank you very much!

All it does is the following:

1. Every week night at 1 AM it builds the latest code using GitHub Actions from the [graphhopper repository](https://github.com/graphhopper/graphhopper) and publishes the image to the GitHub Container Registry (GHCR)
2. It checks for new GraphHopper version tags and, if found, builds and publishes images with the corresponding tag
3. Adds a `graphhopper.sh` helper script for running the image

That's all.

## Quick start

For a quick startup you can run the following command to create the andorra routing:
```
docker run -p 8989:8989 ghcr.io/simonneutert/graphhopper --url https://download.geofabrik.de/europe/andorra-latest.osm.pbf --host 0.0.0.0
```

Then surf to `http://localhost:8989/`

You can also completely override the entry point and use this for example:

```
docker run --entrypoint /bin/bash ghcr.io/simonneutert/graphhopper -c "wget https://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf -O /data/berlin.osm.pbf && java -Ddw.graphhopper.datareader.file=/data/berlin.osm.pbf -Ddw.graphhopper.graph.location=berlin-gh -jar *.jar server config-example.yml"
```

Checkout `graphhopper.sh` for more usage options such as import.


## CI / Publishing

- **Where:** The workflow is [.github/workflows/build-and-publish.yml](.github/workflows/build-and-publish.yml).
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

Feel free to submit issues or pull requests if you would like to improve the code here

This docker image uses the following default environment setting:
```
JAVA_OPTS: "-Xmx1g -Xms1g"
```

CI builds and publishes images to GHCR via GitHub Actions. To build locally use Docker Buildx, for example:

```
docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/<owner>/graphhopper:local .
```
