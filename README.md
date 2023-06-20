# T-rex concurrency issues reproducer

This project allows one to easily benchmark a multithreaded/single-process 
T-rex setup against a multiprocess/single-threaded setup.

# Build

From the current working directory run:

```
docker build -t pdok/lighttpd-trex-perf .
```

# Run multithreaded

From the current working directory run:

```
docker run --rm -p 80:80 -v $PWD:/var/data/in:ro -e CONCURRENCY_TYPE=multithreaded -e THREAD_COUNT=5 -e GPKG_PATH=/var/data/in/all.gpkg -it pdok/lighttpd-trex-perf
```

Now run a load test (note: on macOS replace `localhost` with `host.docker.internal`):

```
docker run --net=host --rm fortio/fortio load -qps 0 -c 5 -t 1m http://localhost/test/2/1/1.pbf
```

When the test is completed observe the results displayed on the last line e.g: "All done 335 calls (plus 5 warmup) 901.165 ms avg, 5.5 qps"

# Run multiprocess

From the current working directory run:

```
docker run --rm -p 80:80 -v $PWD:/var/data/in:ro -e CONCURRENCY_TYPE=multiprocess -e PROCESS_COUNT=5 -e GPKG_PATH=/var/data/in/all.gpkg -it pdok/lighttpd-trex-perf
```

Now run a load test (note: on macOS replace `localhost` with `host.docker.internal`):

```
docker run --net=host --rm fortio/fortio load -qps 0 -c 5 -t 1m http://localhost/test/2/1/1.pbf
```

When the test is completed observe the results displayed on the last line e.g: "All done 1651 calls (plus 5 warmup) 181.996 ms avg, 27.4 qps"
