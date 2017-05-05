---
title: JS深拷贝碰到的问题
tags: JavaScript
date: 2017-04-12 10:18:22
keywords: 前端, JavaScript
---

js的数据类型有：Null Undefined Boolean Number Array String Object 之分，es6后又增加了Symbol，其中分为2大类：基本数据类型和对象类型，同时产生了相应的2个传值方式：赋值和引用；<!--more-->

## 基本数据类型的深拷贝

### 通过JSON

``` js
JSON.parse(JSON.stringify(obj))
```

### 通过简单函数

``` js
function extendCopy(p) {
　　var c = {};
　　for (var i in p) {
　　　　c[i] = p[i];
　　}
　　return c;
}
```

## 引用类型深拷贝

### 引用类型细分

* 基本的JS对象：正则，函数，对象，数组等之分
* 其他JS内置的Date，Error，Math等
* 浏览器内置的window，document等

严格来说，这些对象赋值时都是要考虑的，但常见的对象内部存放的数据类型不会涵盖的这么全面，  
但也需要考虑：正则，函数，对象，数组，Dete，Dom

### 数据类型的识别办法

``` js
var type=Object.prototype.toString.call(Obj).split(/[\[\s\]]/)[2]
```

通过识别type可以确认数据的类型，然后分别针对Array，Object做不同的处理

``` js
let obj1 = {
    a: 11,
    b: 'bb',
    c: new Date(),
    d: function aa () {return 2},
    e:[1,2,3],
    f:new Error('error'),
    g:document.body,
    h:new RegExp(/[111]/)
}
function deepCopy (obj) {
    var type = Object.prototype.toString.call(obj).split(/[\[\s\]]/)[2];
    let temp = type === 'Array' ? [] : type=='Object'? {}:obj;
    if(type=='Array' || type=='Object'){
        for (let val in obj) {
            temp[val] = typeof obj[val] == 'object' ? deepCopy(obj[val]) : obj[val]
        }
    }
    return temp
}
```

如上，实现了深拷贝

## 但深拷贝还有一个坑要填

那就是循环赋值问题；回到前面的

``` js
let obj1 = {  
    a: 11,  
    b: 'bb',  
    c: new Date(),  
    d: function aa () {return 2},  
    e:[1,2,3],  
    f:new Error('error'),  
    g:document.body,  
    h:new RegExp(/[111]/),  
}
obj1.g=obj1  
deepCopy(obj1)

//Uncaught RangeError: Maximum call stack size exceeded  
at RegExp.[Symbol.split] ()  
at String.split (native)  
at deepCopy (:12:50)  
at deepCopy (:16:47)  
at deepCopy (:16:47)  
at deepCopy (:16:47)  
at deepCopy (:16:47)  
at deepCopy (:16:47)  
at deepCopy (:16:47)  
at deepCopy (:16:47)  
```

这是就会出现堆栈溢出的错误。

### 重复引用会有什么问题

例子1：

``` js
var obj={
    a:1
}
obj.b=obj
```

例子2：

``` js
o1={a:1};o2={a:o1};o3={a:o2};o1.a=o3
```

这时去做深拷贝，会陷入无限递归。

### 怎么解决

对象本身就是树形结构，可以用一个数组来保存当前枝叶链上的所有object，如果下层枝叶又引用上层的obj，那就直接赋值，而不是采用递归，从而打破无限递归的深渊。

``` js
var deepCopyArray = [],
    deepType={
        Array:[],
        Object:{}
    },
    deepTypeValue={
        Array:true,
        Object:true
    };

function getType(obj){
    return Object.prototype.toString.call(obj).split(/[\[\s\]]/)[2];
}

function deepCopy(obj) {
    let type =getType(obj);
    let data = type === 'Array' ? [] : type=='Object'? {}:obj;

    if(deepType[type]){
        for (let val in obj) {
            let value=obj[val];
            let subType=getType(value);
            if(deepType[subType]) {
                deepCopyArray = [];
                deepCopyArray.push(obj);
                deepCopyArray.push(value);
                data[val] = deepCopyFn(value)
            }else{
                data[val]=value;
            }
        }
    }
    return data
}



function deepCopyFn(obj){
    let type =getType(obj);
    let data = type === 'Array' ? [] : type=='Object'? {}:obj;

    if(deepType[type]){
        for (let val in obj) {
            let value=obj[val];
            let subType=getType(value);
            let flag=false;
            if(deepType[subType]) {
                for (let i = 0; i < deepCopyArray.length; i++) {
                    if (deepCopyArray[i] === value) {
                        flag = true;
                        break;
                    }
                }
                if (!flag) {
                    deepCopyArray.push(value);
                    data[val] = deepCopyFn(value);
                }else{
                    data[val]=value;
                }
            }else{
                data[val]=value;
            }
        }
    }
    return data
}
```

基本解决深拷贝问题，虽然不完美，但已经可以使用了。  
测试代码：

``` js
var o1 = {a: 1}, o2 = {b: o1}, o3 = {c: o2};

var obj1 = {
    a: 11,
    b: 'bb',
    c: new Date(),
    d: function aa() {
        return 2
    },
    e: [1, 2, 3],
    f: new Error('error'),
    g: document.body,
    h: new RegExp(/[111]/),
    i: o1,
    j: o2,
    k: o3,
    l: {a: o1}
};

obj1.m = obj1;
obj1.n = {
    a: o1,
    b: {
        b: obj1.d,
        c: obj1.i,
        d: obj1.l
    }
};
o1.b = obj1;

obj2 = deepCopy(obj1)
console.log(obj1.a==obj2.a)
console.log(obj1.h==obj2.h)
console.log(obj1.i==obj2.i)
console.log('obj1.i.b----'+(obj1.i.b==obj2.i.b));
console.log(obj1.k==obj2.k)
console.log(obj1.k.c==obj2.k.c)
```