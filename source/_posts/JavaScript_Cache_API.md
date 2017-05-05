---
title: JavaScript获取缓存和清除缓存API
date: 2017-04-14 00:02:17
tags: [JavaScript,API]
keywords: JavaScript,前端,API
---
JavaScript ServiceWorker API 的好处就是让 WEB 开发人员轻松的控制缓存。虽然使用 ETags 等技术也是一种控制缓存的技术，按使用 JavaScript 让程序来控制缓存功能更强大，更自由。当然，强大有强大的好处，也有弊处——你需要做善后处理，所谓的善后处理，就是要清理缓存。

下面我们来看看如何创建缓存对象、在缓存里添加请求缓存数据，从缓存里删除请求缓存的数据，最后是如何完全的删除缓存。<!--more-->

## 判断浏览器对缓存对象`caches` API 的支持

检查浏览器是否支持 Cache API

``` js
if('caches' in window) {
  // Has support!
}
```

检查 `window` 里是否存在 `caches` 对象。

## 创建一个缓存对象

创建一个缓存对象的方法是使用 `caches.open()` ，并传入缓存的名称：

``` js
caches.open('test-cache').then(function(cache) {
  // 缓存创建完成，现在就可以访问了
});
```

这个 `caches.open` 方法返回一个 Promise ，其中的 `cache` 对象新创建出来，如果是以前创建过，就不重新创建。

## 添加缓存数据

对于这类的缓存，你可以把它想象成一个 `Request` 对象数组， `Request` 请求获取的响应数据将会按键值存储在缓存对象里。有两个方法可以往缓存里添加数据：`add` 和 `addAll`。用这两个方法将要缓存的请求的地址添加进去。关于 `Request` 对象的介绍可以参考 [Fetch API](https://developer.mozilla.org/zh-CN/docs/Web/API/Fetch_API) 。

使用 `addAll` 方法可以批量添加缓存请求：

``` js
caches.open('test-cache').then(function(cache) { 
  cache.addAll(['/', '/images/logo.png'])
    .then(function() { 
      // Cached!
    });
});
```

这个 `addAll` 方法可以接受一个地址数组作为参数，这些请求地址的响应数据将会被缓存在cache对象里。`addAll` 返回的是一个 Promise 。添加单个地址使用 `add` 方法：

``` js
caches.open('test-cache').then(function(cache) {
  cache.add('/page/1');  // "/page/1" 地址将会被请求，响应数据会缓存起来。
});
```

`add()` 方法还可以接受一个自定义的 `Request` :

``` js
caches.open('test-cache').then(function(cache) {
  cache.add(new Request('/page/1', { /* 请求参数 */ }));
});
```

跟 `add()` 方法很相似，`put()` 方法也可以添加请求地址，同时添加它的响应数据：

``` js
fetch('/page/1').then(function(response) {
  return caches.open('test-cache').then(function(cache) {
    return cache.put('/page/1', response);
  });
});
```

## 访问缓存数据

要查看已经缓存的请求数据，我们可以使用缓存对象里的 `keys()` 方法来获取所有缓存 `Request` 对象，以数组形式：

``` js
caches.open('test-cache').then(function(cache) { 
  cache.keys().then(function(cachedRequests) { 
    console.log(cachedRequests); // [Request, Request]
  });
});

/*
Request {
  bodyUsed: false
  credentials: "omit"
  headers: Headers
  integrity: ""
  method: "GET"
  mode: "no-cors"
  redirect: "follow"
  referrer: ""
  url: "http://www.example.com/images/logo.png"
}
*/
```

如果你想查看缓存的 `Request` 请求的响应内容，可以使用 `cache.match()` 或 `cache.matchAll()` 方法：

``` js
caches.open('test-cache').then(function(cache) {
  cache.match('/page/1').then(function(matchedResponse) {
    console.log(matchedResponse);
  });
});

/*
Response {
  body: (...),
  bodyUsed: false,
  headers: Headers,
  ok: true,
  status: 200,
  statusText: "OK",
  type: "basic",
  url: "https://www.example.com/page/1"
}
*/
```

关于 `Response` 对象的用法和详细信息，可以参考 [Fetch API](https://developer.mozilla.org/zh-CN/docs/Web/API/Fetch_API) 。

## 删除缓存里的数据

从缓存里删除数据，我们可以使用 cache 对象里的 `delete()` 方法：

``` js
caches.open('test-cache').then(function(cache) {
  cache.delete('/page/1');
});
```

这样，缓存里将不再有 `/page/1` 请求数据。

## 获取现有的缓存里的缓存名称

想要获取缓存里已经存在的缓存数据的名称，我们需要使用 `caches.keys()` 方法：

``` js
caches.keys().then(function(cacheKeys) { 
  console.log(cacheKeys); // ex: ["test-cache"]
});
```

`window.caches.keys()` 返回的也是一个Promise 。

## 删除一个缓存对象

想要删除一个缓存对象，你只需要缓存的键名即可：

``` js
caches.delete('test-cache').then(function() { 
  console.log('Cache successfully deleted!'); 
});
```

大量删除旧缓存数据的方法：

``` js
// 假设`CACHE_NAME`是新的缓存的名称
// 现在清除旧的缓存
var CACHE_NAME = 'version-8';

// ...

caches.keys().then(function(cacheNames) {
  return Promise.all(
    cacheNames.map(function(cacheName) {
      if(cacheName != CACHE_NAME) {
        return caches.delete(cacheName);
      }
    })
  );
});
```

火狐浏览器和谷歌浏览器都支持 service worker，相信很快就会有更多的网站、app 使用这种缓存技术来提高运行速度。