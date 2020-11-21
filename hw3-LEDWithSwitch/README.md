# Homework 3 introduction
LED的循环闪烁，通过switch输入以控制闪烁频率。具体要求可以查看作业要求说明PDF文件csd-assignment-3。

# 实现原理
由于没有使用timer，所以时间间隔由c代码中的循环实现，图中的Delay函数运行完成大约需要0.1 s的时间，输入t值即可实现t * 0.1 s的时间间隔：
![image](https://github.com/Lin-CX/Repository/blob/master/image.png)