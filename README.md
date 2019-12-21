# Android distcc server

Docker image capable of running distcc for android.

Handles any ABI that the NDK supports, does not need separate instances unless you need
various versions of NDK.

Once built, direct port 3632 to any locally exposed port and configure your
clients accordingly. This allows a single machine to host multiple ABIs and APIs

## Why use docker? 

Because it's easy to set up on most any machine, quickly turning it into another server
in your ever growing distcc farm :-)

## Will it make everything super quick and awesome?

Yes! And it also makes a mean espresso while doing so... errmm.. No, not quite. It will
accelerate any NDK based part of your android build, but anything gradle or java will not
be helped by this.

But I have seen a 50 percent (!!) decrease in build time with two servers assigned 12 jobs each and 4 jobs assigned to the machine doing the compilation.

# Setup

## Build time arguments

By using `--build-arg` you can configure the following keys:

- `NDK_VERSION` should be for example `r18b` (default) or `r16b` or similar
- `NDK_PLATFORM` references which architecture you'll be running on (the compilers and such), typically left at `x86_64` but can be changed.

All of this is used when downloading the NDK from Google, the URL is built like this:

`https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-${NDK_PLATFORM}.zip`

## Runtime arguments

Some options can be tweaked for each container since they're environment variables

- `DISTCC_JOBS` defines how many jobs the server will accept at most, the default value is `12` (typical Core i7 with 50% overprovisioning, see FAQ) but can be overridden using `-e` option.

## Setting up the system

To efficiently make use of distcc, it's HIGHLY recommended you also use `ccache` and this README.md makes the assumption that you're doing
just that.

First step, build and run the docker container on your server. This guide assumes you know how that works, but the short version is

```
cd android-distccd
docker build . -t android-distccd
docker run -p 3632:3632 android-distccd
```

Next step, create a `~/.distcc/hosts` file on the client, this should contain a list of all servers that are running this docker image. The simplest format
of this file is:

```
10.0.0.1/12
localhost/4
```

In the above example, we've assigned a maximum of 12 concurrent jobs to 10.0.0.1 and 4 concurrent jobs to localhost (DO NOT USE 127.0.0.1, it will cause problems). You always want a line 
specifying `localhost/<number of jobs>` or no compilation will take place on the client.

*NOTE!* Windows and Mac users have to go into docker desktop settings to enable all cores, or they typically only use 2-4 cores on the system. This is CRUCIAL to utilize the hosts properly

Once this is set up, you have one last thing to do. Android NDK uses `ninja` which is great, unfortunately there is no easy way to convince it to use more threads than the host has cores.

Enter `ninja`, the little shell wrapper found in this repository. It allows you to supply a `-j` argument by setting `NINJA_JOBS`. To install it, simply locate your existing setup, like so:

```
find /path/to/android/sdk -name ninja
```
This should return ONE hit with a complete path to your ninja tool. Start by renaming it to `ninja_org` by issuing `mv /path/to/ninja /path/to/ninja_org`. You should now have a `ninja_org` instead of `ninja`.
Copy the supplied `ninja` wrapper to the same location and make sure it's executable (`chmod +x /path/to/ninja`). I know, not pretty, but it's necessary to hide this new capability from the rest of his friends.

Last, to enable all the magic, you need to set and export two environment variables, `CCACHE_PREFIX` and `NINJA_JOBS`

`CCACHE_PREFIX` should point to `distcc_filter.sh` and `NINJA_JOBS` should be set to the total amount of concurrent jobs your setup can handle, in our example above, it means `18`. We also need to export them
so the tools can pick up on them, so we do this:

```
export CCACHE_PREFIX=/where/you/have/the/repo/distcc_filter.sh
export NINJA_JOBS=18
```
Why do we not point to `distcc` directly? Because some arguments may need filtering or adding. In my experience, we need to stop the `unused arguments` warning, since it will create issues if the compiler is also issued `-Werror` which says warnings are errors. So while compilation will work just fine, you'll still fail due to this. Obviously that is less than ideal and thus this wrapper to make sure it doesn't happen. The resulting output will be the same, we just avoid stalling out the use of the distcc server which caused this warning (failed distcc job will blacklist the server for X minutes).

*ANYWAY...*

Finally, launch Android Studio or kick off your build from the same command line.

If everything works as expected, you may see a print-out saying

```
=== NINJA OVERDRIVE === USING 18 JOBS AS ASKED MASTER ===
```

on your client machine (don't worry if you don't, some build setups simply discard that output) and gradually the server (10.0.0.1 in this case) will start to print out COMPILE messages in the console.

Congratulations, you now have a distcc enabled android build environment.

# Common questions

## How should I configure my distcc setup?

This is my experience:
- For 8 cores, overprovision by 50%, so assign 12 jobs (also the default for the docker image)
- Do not exceed the amount of jobs the distcc server is configured for
- Using LZO compression helps, the overhead is minimal (cpu wise). Just add `,lzo` at the end of the host line
- Don't use all cores on local host. It does the linking and preprocessing. I find using 50% of the cores yields best performance
- Place fastest host first, local host last (again, does the linking and preprocessing)

Of course, your milage will vary and depending on setup, you may want to tweak this.

## I keep getting `ERROR: read failed while waiting for token "DOTI"`

This indicates that you're not using the right compiler version, for example client
is running r16b and server is r18b

## Why are you running all calls through a wrapper on the server?

This is to deal with the arguments sent to the compiler which contain paths. It will automatically detect and replace the client path with the correct server path. It also allows for removal of
arguments which aren't that useful and sometimes causes harm to the compile process (ie, causing error codes which aren't actually errors).

Lastly, it also means this distcc installation can support any ABI, which is super-handy :-)

## How do I monitor this?

Run `distccmon-text` on your client machine, or be lazy and run it via `watch`, like so `watch -n1 distccmon-text` ... This will cause it to automatically refresh every second.

