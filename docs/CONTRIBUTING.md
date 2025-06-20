# 贡献指南

感谢你对本项目的关注！这是一个用于终端登录校园网的工具，我们欢迎任何形式的贡献，包括但不限于：文档优化、BUG修复、UI优化、添加学校等。

## 🧾 如何贡献

### 1. Fork 项目

点击页面右上角的 “Fork” 按钮，将项目复制到你的仓库。

### 2. 创建分支

在 **<your_fork_repo> / Actions / 🆕 New branch** 页面点击 “workflow_dispatch” 根据指示创建 **工作分支** ，以下是分支选择建议：

* **`main/*`**：主分支，同于提交发布版本；
* **`campus/*`**：添加校园网API；
* **`shell/*`**：修改本项目的SHELL模块；
* **`go/*`**：修改本项目的GOLANG模块；


在远端创建分支后，我们需要将其拉取到本地，然后再**对应位置**创建一个 **上游** | `upstream` 为该远端分支的新分支：

```bash
git fetch
git checkout <your_remote_branch>
git branch <your_local_branch> -u <your_remote_branch>
# after work
git push origin <your_local_branch>
```

### 3. Pull Request

推送到你自己的仓库后，在GitHub上提交Pull Request：

* 标题清晰描述更改内容
* 填写`PR`描述，说明变更的目的、影响及测试方式
* 关联相关`Issue`（如果有）

## 🙌 欢迎加入！

欢迎加入 `4 NEXTGENS` 大家庭(现有1人)；