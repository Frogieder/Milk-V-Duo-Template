# Milk-V Duo (S) WiringX project template

This project provides the minimum needed to build a project for all three versions of Milk -V Duo.

This setup has only been tested on Linux, I don't know if it works under Windows or macOS (please, open and issue if it doesn't, and we can look into that)

CLion users can also use this setup with ease.

---

## Setting up 
### First setup
This code depends on having [milkv-duo/duo-examples](https://github.com/milkv-duo/duo-examples/tree/main) downloaded and installed somewhere in your system.
Follow the instructions in the repo to compile one example.

If you successfully compile on the examples, note the path to where your examples are stored on your system, then add it to your environment variables as `MILK_V_PATH`.
On Linux, you can add the following line to your `~/.bashrc`, `~/.zshrc` or whichever shell you use:
```shell
export MILK_V_PATH='/home/USERNAME/SOME_PATH/duo-examples'
```
Alternatively, you can comment out line 14 in `CMakeLists.txt`, uncomment the line 15 and write the path to `duo-examples` there.

### Per-project settings
Before compiling, you'll need to choose your board on lines 6~11 in `CMakeLists.txt`.
Choose the right combination of board name and architecture for what you're using.

Be sure to also change the project name on line 2 in `CMakeLists.txt` and in `compile_and_run` to suit your needs.

---

## Building and run
### Using a script
The easiest way to build and run the code is using the provided script:
```shell
./compile_and_upload.sh
```
By default, the scripts builds the project and uploads it to the board.
If you have `sshpass` installed, it uses the file `ssh_password.txt` and enters the password for you.
Supported flags for the script are `--run`, `--no-upload` and `--help`.

### Manually
To build the project manually, enter the following commands in the root directory
```shell
mkdir build
cd build
cmake ..
make
```

The upload can then be done by running
```shell
scp -O blink root@192.168.42.1:/root/
```