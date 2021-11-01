# Docker image with CMake, Ninja, Gcc and Qt

This docker image is used to run continuious integrations and local builds with the CMake meta build system.

The image contains a Gcc as the main compiler.
The Qt variants also contain some Qt module.

## Usage

Use it like cmake command line.

```bash
docker run -it --rm \
    --mount src="$(pwd)",target=/project,type=bind -w /project \
    --mount src=project-build,target=/project/build,type=volume \
    cmake-gcc11:latest \
    -S . --preset "Gcc"

docker run -it --rm \
    --mount src="$(pwd)",target=/project,type=bind -w /project \
    --mount src=project-build,target=/project/build,type=volume \
    cmake-gcc11:latest \
    --build --preset "Gcc" --config "Debug"
```

This mounts your current directory to `/project` and a build volume in the container. Changes the workdir to `/project` and runs cmake with various arguments.
