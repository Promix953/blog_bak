---
title: 深入理解JavaScript-replace
date: 2017-04-13 23:10:56
tags: JavaScript
keywords: JavaScript,前端,replace
---
replace 方法是属于 String 对象的，可用于替换字符串。

## 简单介绍:

`String.replace(searchValue, replaceValue)`

1.  String：字符串
2.  searchValue：字符串或正则表达式
3.  replaceValue：字符串或者函数
<!--more-->
## 字符串替换字符串

``` js
'I am loser!'.replace('loser', 'hero')
//I am hero!
```

直接使用字符串能让自己从 loser 变成 hero，但是如果有 2 个 loser 就不能一起变成 hero 了。

``` js
'I am loser,You are loser'.replace('loser', 'hero');
//I am hero,You are loser 
```

## 正则表达式替换为字符串

``` js
'I am loser,You are loser'.replace(/loser/g, 'hero')
//I am hero,You are hero
```

使用正则表达式，并将正则的 global 属性改为 true 则可以让所有 loser 都变为 hero

## 有趣的替换字符

`replaceValue` 可以是字符串。如果字符串中有几个特定字符的话，会被转换为特定字符串。

字符            | 替换文本          
------------- | --------------
$&            | 与正则相匹配的字符串    
$`            | 匹配字符串左边的字符    
$'            | 匹配字符串右边的字符    
$1,$2,$3,…,$n | 匹配结果中对应的分组匹配结果

### 使用 $& 字符给匹配字符加大括号

``` js
var str='讨论一下正则表达式中的replace的用法';
str.replace(/正则表达式/, '{$&}');
//讨论一下{正则表达式}中的replace的用法
```

### 使用 $` 和 $' 字符替换内容

``` js
'abc'.replace(/b/, "$`"); //aac
'abc'.replace(/b/, "$'"); //acc
```

### 使用分组匹配组合新的字符串

``` js
'admin@example.com'.replace(/(.+)(@)(.*)/, "$2$1") //@admin
```

## replaceValue参数可以是一个函数

`String.replace(searchValue,replaceValue)` 中的 **replaceValue** 可以是一个函数.

如果 replaceValue 是一个函数的话那么，这个函数的 arguments 会有 n+3 个参数（ n 为正则匹配到的次数）

**先看例子帮助理解：**

``` js
function logArguments(){    
    console.log(arguments);
    //["admin@example.com", "admin", "@", "example.com", 0, "admin@example.com"] 
    return '返回值会替换掉匹配到的目标'
}
console.log(
    'admin@example.com'.replace(/(.+)(@)(.*)/, logArguments)
)
```

**参数分别为**

1.  匹配到的字符串（此例为 admin@example.com ,推荐修改上面代码的正则来查看匹配到的字符帮助理解)
2.  如果正则使用了分组匹配就为多个否则无此参数。（此例的参数就分别为`"admin", "@", "example.com"`。推荐修改正则为 /admin/ 查看控制台中返回的 arguments 值）
3.  匹配字符串的对应索引位置（此例为0）
4.  原始字符串 ( 此例为 'admin@example.com' )

### 使用自定义函数将 A-G 字符串改为小写

``` js
'JAVASCRIPT'.replace(/[A-G]/g, function(){
    return arguments[0].toLowerCase();
}) //JaVaScRIPT 
```

### 使用自定义函数做回调式替换将行内样式中的单引号删除

``` js
'<span style="font-family:\'微软雅黑\';">;demo</span>'.replace(/\'[^']+\'/g, function(){      
    var result = arguments[0];
    console.log(result); //'微软雅黑'
    result = result.replace(/\'/g, '');
    console.log(result); //微软雅黑
    return result;
}) //<span style="font-family:微软雅黑;">demo</span> 
```
