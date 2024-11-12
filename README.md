# flutter_test_project

A new Flutter project.

## Getting Started

## qweather 加密

[JSON Web Token | 和风天气开发服务](https://dev.qweather.com/docs/authentication/jwt/)

### 使用 GPG 加密

GPG 支持使用对称加密的方式，即仅使用密码进行加解密，而不涉及公钥和私钥。这种方式适用于你希望使用一个简单的密码来保护文件的情况。下面是如何使用 GPG 进行对称加密和解密的步骤：

#### 对称加密

1. **安装 GPG**：确保你的系统上已经安装了 GPG。如果没有安装，可以通过包管理器来安装，例如在 Ubuntu 上使用 `sudo apt-get install gnupg`，macOS 使用 `brew install gpg`。

2. **加密文件**：使用 `gpg` 命令并指定对称加密算法（如 AES-256）来加密文件。命令如下：
   ```bash
   gpg --symmetric --cipher-algo AES256 filename
   ```
   这里，`filename` 是你要加密的文件名。执行该命令后，GPG 会提示你输入一个密码。输入密码后，GPG 会生成一个加密后的文件，文件名通常是 `filename.gpg`。

#### 对称解密

1. **解密文件**：使用 `gpg` 命令来解密文件。命令如下：
   ```bash
   gpg --output decryptedfile.txt --decrypt filename.gpg
   ```
   这里，`decryptedfile.txt` 是输出的解密后的文件名，而 `filename.gpg` 是输入的加密文件名。执行该命令后，GPG 会提示你输入加密时使用的密码。
