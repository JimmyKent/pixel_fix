# pixel_fix

[![pub package](https://img.shields.io/pub/v/pixel_fix.svg)](https://pub.dev/packages/pixel_fix)

Plugin for adapting Android and iOS screen size.

## Usage:

### Add dependency：

```yaml
dependencies:
  pixel_fix: ^0.0.1
```

### Add import:

```dart
import 'package:pixel_fix/pixel_fix.dart';
```

### init:

```dart
void main() {
  InnerWidgetsFlutterBinding.initPixel(1242, 3);
}
```
### use:	
```dart
void main() {
  InnerWidgetsFlutterBinding.ensureInitialized()
    ..attachRootWidget(MyApp())
    ..scheduleWarmUpFrame();
}
```
原理：  
​基于修改系统的缩放值来实现改变系统绘制的大小。

具体实现：  
重写主要是createViewConfiguration这个方法

优缺点：  
1、不能动态设置ratio值，即不能根据屏幕宽高和设计稿的比例获取真实比例(不能兼容不同设计稿)  
2、用法简单：在使用是没有任何要求，与flutter原生相同。开发人员无感知  
3、因为手动重写了gestures/binding.dart的一些方法，随着Flutter版本的升级，需要不断修改InnerWidgetsFlutterBinding的代码。  