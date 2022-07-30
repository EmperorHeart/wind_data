capture program drop wind_data
program wind_data
version 15.0
*可以解决变量中夹杂没有年份的那种数据，比如注册资本
cap drop if 证券简称==""
cap drop if 证券名称==""
di _skip(45) "欢迎使用一键转化Wind或Choice面板数据命令"
di _newline as error "注意：同一变量内所有时间的数据格式需要一致！！！"
*di _skip(4) _newline as error "只需输入一个数据频率参数，年度用year或y,季度用quarter或q，默认不写为年度"

*简化名字*
if "`1'"=="year" | "`1'"=="y" | "`1'"==""{

order _all,alpha      //在逐个截取名字之前，一定要排序。【都是目前不会去重导致的】
cap order 证券代码 证券简称
cap order 证券代码 证券名称

local qians=""
foreach var of varlist _all{

	if regexm("`var'","([0-9][0-9][0-9][0-9])"){
				local z=regexs(0)
                 }
			 
local pos=strpos("`var'","`z'")        //年份位置
local qian=substr("`var'",1,`pos'-1)  //变量前缀
	 
local newname="`qian'"+"`z'" 

local qians="`qians' "+"`qian'"   //变量前缀集合

cap rename `var' `newname'     //改名

}

*下面是为了去重，要是以后有更好的办法，可以改变这里*

local qians=strtrim("`qians'")    //掐头去尾剔除空格
local _pos=strpos("`qians'"," ")    //确定第一个空格，准备截取第一个名字
local unions=substr("`qians'",1,`_pos'-1)  //截取第一个名字
local z="`unions'"               //去重过程中的中间变量
foreach qian of local qians{

if "`qian'"=="`z'"{
continue
     }
local z="`qian'"          //去重中间变量
local unions="`unions' "+"`z'"

}

cap reshape long `unions',i(证券代码 证券简称) j(year)
cap reshape long `unions',i(证券代码 证券名称) j(year)
renvarlab,subst("报告期" )
renvarlab,subst("交易日期" )
renvarlab,subst("百万元" )   
renvarlab,subst("万元" )
renvarlab,subst("千元" )
renvarlab,subst("元" )
  }
  
if "`1'" == "quarter" | "`1'" == "q"{

order _all,alpha    
cap order 证券代码 证券简称
cap order 证券代码 证券名称

local qians=""
foreach var of varlist _all{

	if regexm("`var'","([0-9]+)"){
				local z=regexs(0)
                 }
		 if strlen("`z'")>4{
		     local z=substr("`z'",1,6)
			 local q=""
			 }
local pos=strpos("`var'","`z'")        //年份位置
local qian=substr("`var'",1,`pos'-1)  //变量前缀
      if regexm("`var'", "一季"){
	        local q="03"
	                 }
      if regexm("`var'", "中报"){
	       local q="06" 
	                 }
		if regexm("`var'", "三季"){
		       local q="09" 
		             }	 
          if regexm("`var'", "年报"){
		        local q="12" 
		  }

local newname="`qian'"+"`z'"+"`q'"

local qians="`qians' "+"`qian'"   //变量前缀集合

cap rename `var' `newname'     //改名

}

*下面是为了去重，要是以后有更好的办法，可以改变这里*

local qians=strtrim("`qians'")    //掐头去尾剔除空格
local _pos=strpos("`qians'"," ")    //确定第一个空格，准备截取第一个名字
local unions=substr("`qians'",1,`_pos'-1)  //截取第一个名字
local z="`unions'"               //去重过程中的中间变量
foreach qian of local qians{

	if "`qian'"=="`z'"{
		continue
			}
local z="`qian'"          //去重中间变量
local unions="`unions' "+"`z'"

}

cap reshape long `unions',i(证券代码 证券简称) j(_quarter)
cap reshape long `unions',i(证券代码 证券名称) j(_quarter)
 **扫尾工作
qui{
tostring _quarter,force replace
g year=ustrleft(_quarter,4)
destring year,force replace
g _q=ustrright(_quarter,2)
destring _q,force replace
g q=_q/3
g quarter=yq(year,q)
format quarter %tq
drop _quarter _q
cap sort 证券代码 证券简称 year q
cap sort 证券代码 证券名称 year q

cap order 证券代码 证券简称 year q quarter
cap order 证券代码 证券名称 year q quarter

renvarlab,subst("报告期" )
renvarlab,subst("交易日期" )
renvarlab,subst("百万元" )   
renvarlab,subst("万元" )
renvarlab,subst("千元" )
renvarlab,subst("元" )

}
}
 
di as result "---------------转换结束！若转换未成功，请检验您的数据是否满足同一变量所有年份同类型的要求，在重新导入数据进行操作-------------"
end
