# UNIX Build Notes

These notes provide guidance on how to build EFUS Core on Unix-based systems.

**Note:** For BSD-specific instructions, refer to the [build-openbsd.md](build-openbsd.md) and [build-netbsd.md](build-netbsd.md) files.

## Base Build Dependencies

Before building EFUS Core, you need to install essential build tools and libraries.

### Installing Dependencies

Run the following commands based on your operating system to install the required packages:

#### Debian/Ubuntu

\`\`\`bash
sudo apt-get install curl build-essential libtool autotools-dev automake pkg-config python3 bsdmainutils bison libsqlite3-dev
\`\`\`

#### Fedora

\`\`\`bash
sudo dnf install gcc-c++ libtool make autoconf automake python3 libstdc++-static patch sqlite-devel
\`\`\`

#### Arch Linux

\`\`\`bash
sudo pacman -S base-devel python3
\`\`\`

#### Alpine Linux

\`\`\`bash
sudo apk --update --no-cache add autoconf automake curl g++ gcc libexecinfo-dev libexecinfo-static libtool make perl pkgconfig python3 patch linux-headers
\`\`\`

#### FreeBSD/OpenBSD

\`\`\`bash
pkg_add gmake libtool
pkg_add autoconf # Select the highest version, e.g., 2.69
pkg_add automake # Select the highest version, e.g., 1.15
pkg_add python   # Select the highest version, e.g., 3.5
\`\`\`

For more details on specific versions, see [dependencies.md](dependencies.md).

## Building EFUS Core

Follow the instructions in [build-generic.md](build-generic.md) to build EFUS Core.

## Security Features

To enhance the security of your EFUS Core installation, certain hardening features are enabled by default. These features help mitigate the risk of certain attacks even if vulnerabilities are discovered.

### Hardening Flags

The following flags control the hardening features:

- **Enable Hardening:** `./configure --prefix=<prefix> --enable-hardening`
- **Disable Hardening:** `./configure --prefix=<prefix> --disable-hardening`

### Hardening Features

- **Position Independent Executable (PIE):**
  - Builds position-independent code to leverage Address Space Layout Randomization (ASLR), which randomizes the memory addresses used by system and application processes.
  - This makes it more difficult for attackers to predict the location of critical data structures.
  - To verify PIE is enabled, use:
    \`\`\`bash
    scanelf -e ./efusd
    \`\`\`
    The output should include `TYPE ET_DYN`.

- **Non-Executable Stack:**
  - Ensures that the stack is not executable, preventing stack-based buffer overflow exploits.
  - Verify the stack is non-executable with:
    \`\`\`bash
    scanelf -e ./efusd
    \`\`\`
    The output should show `STK RW-`, indicating a non-executable stack.

## Disable-Wallet Mode

If you plan to run only a P2P node without a wallet, you can compile EFUS Core in disable-wallet mode:

\`\`\`bash
./configure --prefix=<prefix> --disable-wallet
\`\`\`

In this mode, EFUS Core does not depend on Berkeley DB 4.8 or SQLite. Mining is still possible using the `getblocktemplate` RPC call.

## Additional Configure Flags

To view a full list of available configure flags, run:

\`\`\`bash
./configure --help
\`\`\`

## Building on FreeBSD

(TODO: This section is untested. Please report any issues and suggest improvements.)

Building on FreeBSD is similar to building on Linux, with the main difference being the use of `gmake` instead of `make`.

**Note on Debugging:** The default `gdb` version on FreeBSD is outdated and unsuitable for debugging multithreaded C++ programs. Install the latest `gdb` package and use the versioned command, e.g., `gdb7111`.

## Building on OpenBSD

(TODO: This section is untested. Please report any issues and suggest improvements.)

**Important:** From OpenBSD 6.2 onwards, a C++11-supporting Clang compiler is included in the base system. Ensure this compiler is used by appending `CC=cc CXX=c++` to configuration commands.

\`\`\`bash
cd depends
make CC=cc CXX=c++
cd ..
export AUTOCONF_VERSION=2.69 # Replace with your installed autoconf version
export AUTOMAKE_VERSION=1.15 # Replace with your installed automake version
./autogen.sh
./configure --prefix=<prefix> CC=cc CXX=c++
gmake # Use -jX for parallelism
\`\`\`

## OpenBSD Resource Limits

If you encounter out-of-memory errors during the build, adjust the resource limits as follows:

OpenBSD has strict default `ulimit` restrictions:

\`\`\`bash
data(kbytes)         1572864
\`\`\`

This may not be sufficient to compile some `.cpp` files. If your user is in the `staff` group, you can raise the limit with:

\`\`\`bash