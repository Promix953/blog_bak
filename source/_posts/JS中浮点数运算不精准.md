---
title: JS中浮点数运算不精准
date: 2017-04-03 21:51:41
tags: JavaScript
---
Javascript采用了IEEE-745浮点数表示法，这是一种二进制表示法，可以精确地表示分数，比如1/2，1/8，1/1024。遗憾的是，我们常用的分数都是十进制分数1/10，1/100等，二进制浮点数表示法并不能精确的表示类似0.1这样的简单的数字。所以会有js中浮点数运算不精准的问题出现，我们一般会重写js的四则运算。下面主要看看解决js中浮点数运算不精准的具体方法。<!--more-->  
下面先看看几个JS四则运算的例子，你一定会很惊讶和自己想想的结果不太一样。  
``` js
js加法：9.3+0.3;//结果为9.600000000000001
js加法：9.3-0.7;//结果为8.600000000000001
js乘法：7*0.8;//结果为5.6000000000000005
js除法：9.3/0.3;//结果为31.000000000000004
```
下面看看具体的解决办法，思路就是把浮点数先转换为整数再运算，运算后再对结果转换为小数：  
**JS加法函数**
``` sh
function accAdd(arg1,arg2){
    var r1,r2,m;
    try{r1=arg1.toString().split(".")[1].length}catch(e){r1=0}
    try{r2=arg2.toString().split(".")[1].length}catch(e){r2=0}

    m=Math.pow(10,Math.max(r1,r2))
    return (arg1\*m+arg2\*m)/m
}
```
**JS减法函数**
``` sh
function Subtr(arg1,arg2){
    var r1,r2,m,n;
    try{r1=arg1.toString().split(".")[1].length}catch(e){r1=0}
    try{r2=arg2.toString().split(".")[1].length}catch(e){r2=0}

    m=Math.pow(10,Math.max(r1,r2));
    //动态控制精度长度

    n=(r1>=r2)?r1:r2;
    return ((arg1\*m-arg2\*m)/m).toFixed(n);
}
```
**JS乘法函数**
``` sh
function accMul(arg1,arg2){
    var m=0,s1=arg1.toString(),s2=arg2.toString();
    try{m+=s1.split(".")[1].length}catch(e){}
    try{m+=s2.split(".")[1].length}catch(e){}
    return Number(s1.replace(".",""))\*Number(s2.replace(".",""))/Math.pow(10,m)
}
```
**JS除法函数**
``` sh
function accDiv(arg1,arg2){
    var t1=0,t2=0,r1,r2;
    try{t1=arg1.toString().split(".")[1].length}catch(e){}
    try{t2=arg2.toString().split(".")[1].length}catch(e){}
    with(Math){
        r1=Number(arg1.toString().replace(".",""))
        r2=Number(arg2.toString().replace(".",""))
        return (r1/r2)\*pow(10,t2-t1);
    }
}
```