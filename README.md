<p align="center">
  <img src="etc/logo.png" alt="campus-ntc logo" width="150" style="border-radius: 50%;">
</p>

<h1 align="center">🛜 Campus-NTC | 终端校园网登录工具</h1>

<div align="center">

![version](https://img.shields.io/badge/version-0.0.1-blue)
![zsh-compatible](https://img.shields.io/badge/shell-zsh-brightgreen)
![license](https://img.shields.io/badge/license-MIT-green)

</div>

<center>

一个基于 `zsh` 的命令行工具，用于简洁高效地登录和登出校园网。提供多用户配置和连接方式，支持中英文输出。

</center>

## 环境要求

`Campus-NTC` 需要用户电脑支持如下功能：

* Unix-like 操作系统（Linux/macOS）
* 已下载并配置 `zsh` 命令行解释器
* 终端支持：中英文字符、`emoji`、彩色输出

## 安装与卸载

### 1. 安装

执行如下命令安装 `Campus-NTC` 命令行工具：

```shell
# Download repository
git clone --depth 1 https://github.com/yourname/campus-ntc.git $HOME/.local/share/campus-ntc  
# Install command
chmod +x $HOME/.local/share/campus-ntc/src/zsh/install.sh
zsh $HOME/.local/share/campus-ntc/src/zsh/install.sh
```

在安装后请确保 `~/.zshrc` 中配置了环境变量 `PATH` ：

```shell
export PATH="$HOME/.local/bin:$PATH"  # Add local bin directory to PATH
```

### 2. 卸载

```shell
zsh $HOME/.local/share/campus-ntc/src/zsh/uninstall.sh    # Uninstall command
rm -rf $HOME/.local/share/campus-ntc    # Remove repository
```

## 使用方法

我们首先需要执行 `cntc configure` 初始化 `Campus-NTC` 的全局配置：

```shell
cntc configure
```

然后我们就使用 `cntc` 命令，访问所有功能：

```shell
cntc [command] [options]
```

**命令总览**：

| 命令              | 说明        |
| --------------- | --------- |
| `config`        | 命令行配置全局设置 |
| `configure`     | 交互式配置全局设置 |
| `user`          | 管理校园网用户信息 |
| `login`         | 登录校园网     |
| `logout`        | 登出校园网     |
| `-v`, `version` | 显示版本信息    |
| `-h`, `--help`  | 显示帮助信息    |

## 相关文档

* **TODO LIST**：[TODO.md](./docs/TODO.md)
* **贡献文档**：[CONTRIBUTING.md](./docs/CONTRIBUTING.md)

## 开源许可证
本项目使用 [MIT License](./LICNESE)。