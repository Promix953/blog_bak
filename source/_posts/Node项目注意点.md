---
title: Node 项目注意点
tags: [Node.js, JavaScript]
date: 2017-04-12 18:42:37
keywords: Nodejs, 前端, ES6, JavaScript
---
随着语言，工具，运行环境，开发方式的不断变化，你的 node 项目当然也需要不断的与时俱进，那么我们就依次来看看需要注意哪些问题吧。
<!-- more --> 
### 现在开始使用 ES2015

- 箭头函数
- 模板字符串
- rest参数，扩展运算符(spread),函数默认值
- 变量的解构赋值
- generator 和 promises
- maps，sets 和 symbols

在服务器端的推荐使用新的 node 解释器支持的语法，或者可以用babel作为compile层（具体做法参考[脚手架](https://github.com/gf-rd/gf-skeleton-node)）

``` js
// 从 express's req.query 解构 特定参数 ?page=2&size=10&word=测试

let {page, size, word} = req.query;

```

### 异步函数支持回调惯例和Promise新写法
过去，当Promise没有成为Node默认搭载的语法时，推荐模块通过导出 error-first callback 的接口形式。但是现在通常需要支持两种形式：

``` js
const fs = require('fs')

function readPackage(callback=noop) {
  return new Promise((resolve, reject)=>{
    fs.readFile('./package.json', (err, data)=>{
      if(err) {
        reject(err)
        return callback(err)
      }
      resolve(data)
      return callback(null, data)
    })
  })
}
```

### 异步模式
过去很长时间，在 node 中一般有两种方式来管理异步流：callback回调和 streams 流
前者可以用辅助我们异步操作的 async 类库
后者可以用through, bl or highland 这些类库
但是随着 es6的 generator和promise的到来，甚至es7的 await/async 内建关键字的到来，情况变了。 详细请看 [异步JavaScript的演进](https://blog.risingstack.com/asynchronous-javascript/)

### 错误处理
完善合理的错误处理让你的服务更加强健。知道何时crash，然后是仅仅catch后忽略，还是记下调用栈打入log后重试，甚至是需要重启？
我们通常需要区别对待 programmer error, operational errors:
前者直接重启（事实上在开发阶段就该发现，并且线上通过 logger 定位），因为程序员写的bug，如果不及时重启会导致应用的状态难以推演，从而发生更多更大的问题
而后者，通常不是bug，而是没有考虑全的case。如外部请求超时了，外部依赖的数据库连不上了，甚至所在运行的机器磁盘写满了，要访问写入的文件暂时不存在了。这些case一般需要在程序里加上特定的fallback/polyfill 来处理。如对于超时的重试几次，对于不存在的文件先试着创建新文件，对于总是塞满磁盘的log，通过logstash和logrotate去处理。

#### 回调中的错误处理
error-first 约定的callback，始终记得在函数开始检查第一个err是否存在，然后进行合适的处理（当然也可以通过 next(e) 传入到调用栈的最后统一处理）

#### Promise中的错误处理 
始终记得在 promise 调用链的最后加上 catch 来处理异常

### 使用标准的 JavaScript 代码风格
过去我们使用 jslint, jshint, jscs 来作为我们的代码风格检查工具，但是随着 es6 的流行，还有一些新的习惯的养成，我们推荐使用 eslint 工具，同时配合 eslint-plugin-standard 插件

``` json
{
  "plugins": [
    "standard"
  ],
}
```

### Web 应用开发的十二条军规
来自于 Rails 社区的血泪经验，但是大部分也是适用于我们Node项目 (一些实践可能在新的docker部署下会有小调整）

- [一份基准代码Codebase，多份部署deploy](http://12factor.net/zh_cn/codebase)
- [显示声明和隔离依赖](http://12factor.net/zh_cn/dependencies)
- [在配置放在环境中](http://12factor.net/zh_cn/config)
- [把外部后端服务当做附加资源](http://12factor.net/zh_cn/backing-services)
- [严格分离构建和运行环境](http://12factor.net/zh_cn/build-release-run)
- [以一个或多个无状态进程运行应用](http://12factor.net/zh_cn/processes)
- [通过端口绑定(Port binding)来提供服务](http://12factor.net/zh_cn/port-binding)
- [通过进程模型进行扩展](http://12factor.net/zh_cn/concurrency)
- [快速启动和优雅终止可最大化健壮性](http://12factor.net/zh_cn/disposability)
- [尽可能的保持开发，预发布，线上环境相同](http://12factor.net/zh_cn/dev-prod-parity)
- [把日志当作事件流](http://12factor.net/zh_cn/logs)
- [后台管理任务当作一次性进程运行](http://12factor.net/zh_cn/admin-processes)

### 始终用 npm init 开始新项目
通过 npm init 来初始化你的node项目，通过promt 确定你的项目名称，开发者信息等（当然你可以通过 --yes 旗标来跳过）
Tip: 主要你应该总是显示指名你的node engines 版本（node -v），确保你的开发环境，测试环境和线上环境是用同一版本的 node.

``` json
{
  "engines": {
    "node": "6.10.2"
  }
}
```


### 文件名始终小写
因为在 OSX 和 Windows 系统中，MyClass.js 和 myclass.js 没有任何区别，Linux 则会区分。所以为了你写的代码在不同操作系统是可移植的（在使用 require 来引入模块确保语句是一致明确的），所以始终保持小写 - my-class.js

### 智能的.npmrc 和正确的版本管理做法
默认上， npm 在安装新的依赖的modules，默认不会加入到package.json中。同时，modules的版本号不是严格锁死的（^尖角号来确保大版本保持一致）这样会造成一些问题，如在发布时才发现没有把依赖写入到package.json中，造成线上缺少必要的模块，线上部署发现用的不是相同的modules，导致莫名其妙的问题和大量的depricated warning警告。

所以安装新依赖推荐这样的写法：`npm install foobar --save --save-exact`
或者写入.npmrc 这样下次 npm install 就不会犯错啦

``` sh
$ npm config set save=true
$ npm config set save-exact=true
$ cat ~/.npmrc
```

如果如果希望更灵活的依赖控制，可以通过 `npm shrinkwrap` 命令生成 `npm-shrinkwrap.json` 加入到版本库中，这样在build环境构建也能保证版本统一。

### 及时更新依赖
上面的版本锁死让你面对依赖模块的时候更加从容，但是要记得保持定期更新依赖，从而获得修复bug和性能优化功能完善的更新。可以每周利用 `npm outdated` 或 [ncu 工具包](https://www.npmjs.com/package/npm-check-updates)

### 选择合适的数据库
大部分新的noder，在选择数据库，喜欢选择Mongodb。它的确很不错，但是 Mongodb 不是唯一的选择、
你应该根据你的应用场景来选择：

- 你的数据是否结构化的
- 你的数据操作是否要支持事务
- 你数据是否需要持久化

从而选择不同的数据库：如 PostgreSQL， Redis, LevelDB 等等

### 监控你的应用程序
你要对你的线上应用的运行状况了如指掌（CPU，Memory，日志等），对一些突发情况需要及时获得通知。
很多开源项目和SaaS产品都提供完善强大的监控服务，如Zabbix, Collectd, ElasticSearch 和 Logstash. 甚至结合Cabot给微信公众号发消息提醒等等

### 使用构建系统
现在的JavaScript的工具链有大量的选择： Grunt, Gulp, Webpack等。譬如在团队里，我们选择 Webpack 来辅助前端开发，gulp用来处理大量其他的自动化任务（你的shell脚本也可以通过gulp-shell集成进来）。当然我们也推荐使用 vanilla build （尤其你可以结合 npm lifecycle hooks 完成很多事）

### NPM 生命周期钩子
提供了很好的钩子来使得一些task实现的很优雅，[脚手架](https://github.com/gf-rd/gf-skeleton-node)大量使用了这样的技巧

``` shell
"postinstall": "bower install && grunt build",

"postinstall": "if $BUILD_ASSETS; then npm run build-assets; fi",
"build-assets": "bower install && grunt build"

# 如果脚本变复杂可以单独文件：
"postinstall": "scripts/postinstall.sh” (sh 脚本中会自动可以访问到 ./node_modules/.bin 中的命令，因为该路径被加入到 $PATH)
```

### 管好垃圾回收
v8默认使用 lazy 和 贪婪的 GC.  有时候等到1.5GB 自由才去回收未被使用的内存 (所以有时候内存涨不是因为泄露还是[node’s usual lazy behavior]())

所以你不想自己的node应用经常把服务器的内存占满（或者你不得不调整，因为你的机器可用内存没那么多），试着使用下面的命令/proc 文件来启动 node 服务（推荐写在 .pm2config 中，正如脚手架推荐的）

``` shell
web: node --optimize_for_size --max_old_space_size=920 --gc_interval=100 server.js
```

### 使用长期支持的 Node.js 版本
如果你需要在不同项目中工作，并且不同项目用的node版本还不一样，可以使用 node version manager([nvm](https://github.com/creationix/nvm))

### 使用语义化的版本号
通过三段版本数来确保把兼容性声明好。 major.minor.patch 这样的格式，不同级别的升级对API更新的要求也是不一样的。可以通过[semantic-release](https://github.com/semantic-release/semantic-release) 来让版本升级更加自动化

### 持续学习和跟上潮流
JavaScript 和 Node.js 社区异常活跃，的确是件好事。每周都有新的工具新的理念的加入，让我们始终保持热情和技术的提升（警惕自己变成跟风狗，要取色和了解每个新东西背后的不变的本质），不要待在自己的蜜罐中，要动手做试验和学习。以下资料：

- Node.js Weekly Newsletter
- Microservice Weekly Newsletter
- Changelog Weekly - for Open-Source news

### 参考

- [How to Become a Better Node.js Developer](https://blog.risingstack.com/how-to-become-a-better-node-js-developer-in-2016/)
- [10 habits of a happy node hacker 2016](https://blog.heroku.com/archives/2015/11/10/node-habits-2016)
- [Web 服务开发的十二条军规](http://12factor.net/zh_cn)
