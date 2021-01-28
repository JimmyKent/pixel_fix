import 'dart:async';
import 'dart:collection';

import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class InnerWidgetsFlutterBinding extends WidgetsFlutterBinding {
  static int _uiWidth;
  static double _uiRatio;

  /// [uiWidth] ui设计稿的宽度
  /// [uiRatio] ui设计稿的宽度对应的像素密度, 比如 1242 对应的是 3
  static void initPixel(int uiWidth, double uiRatio) {
    _uiWidth = uiWidth;
    _uiRatio = uiRatio;
  }

  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) {
      InnerWidgetsFlutterBinding();
    }
    return WidgetsBinding.instance;
  }

  /// 根据比例换算, 得到当前屏幕的像素密度
  static double _getPixelRatio() {
    return _uiRatio / _getPixelRate();
  }

  /// 设计稿px和屏幕物理屏幕px之比
  static double _getPixelRate() {
    return _uiWidth / window.physicalSize.width;
  }

  /// 需要保证 size * devicePixelRatio = 屏幕宽高
  /// 代码中写的 宽高 * devicePixelRatio = 在屏幕上显示的px值
  @override
  ViewConfiguration createViewConfiguration() {
    return ViewConfiguration(
      // 保证页面的虚拟大小和缩放比例
      size: window.physicalSize / _getPixelRatio(),
      devicePixelRatio: _getPixelRatio(),
    );
  }

  final Queue<PointerEvent> _pendingPointerEvents = Queue<PointerEvent>();

  ///
  /// 重写GestureBinding（手势绑定）的初始化函数
  /// 唯一目的是把_handlePointerDataPacket方法再原始数据转换改用修改过的 PixelRatio
  ///
  @override
  void initInstances() {
    super.initInstances();
    window.onPointerDataPacket = _handlePointerDataPacket;
  }

  @override
  void cancelPointer(int pointer) {
    if (_pendingPointerEvents.isEmpty && !locked) {
      scheduleMicrotask(_flushPointerEventQueue);
    }
    _pendingPointerEvents.addFirst(PointerCancelEvent(pointer: pointer));
  }

  @override
  void unlocked() {
    super.unlocked();
    _flushPointerEventQueue();
  }

  void _handlePointerDataPacket(PointerDataPacket packet) {
    _pendingPointerEvents.addAll(PointerEventConverter.expand(
        packet.data,
        // 适配事件的转换比率,采用tieba适配之后的
        _getPixelRatio()));
    if (!locked) {
      _flushPointerEventQueue();
    }
  }

  void _flushPointerEventQueue() {
    assert(!locked);
    while (_pendingPointerEvents.isNotEmpty)
      _handlePointerEvent(_pendingPointerEvents.removeFirst());
  }

  /// State for all pointers which are currently down.
  ///
  /// The state of hovering pointers is not tracked because that would require
  /// hit-testing on every frame.
  final Map<int, HitTestResult> _hitTests = <int, HitTestResult>{};

  void _handlePointerEvent(PointerEvent event) {
    assert(!locked);
    HitTestResult hitTestResult;
    if (event is PointerDownEvent || event is PointerSignalEvent) {
      assert(!_hitTests.containsKey(event.pointer));
      hitTestResult = HitTestResult();
      hitTest(hitTestResult, event.position);
      if (event is PointerDownEvent) {
        _hitTests[event.pointer] = hitTestResult;
      }
      assert(() {
        // ignore: always_put_control_body_on_new_line
        if (debugPrintHitTestResults) debugPrint('$event: $hitTestResult');
        return true;
      }());
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      hitTestResult = _hitTests.remove(event.pointer);
    } else if (event.down) {
      // Because events that occur with the pointer down (like
      // PointerMoveEvents) should be dispatched to the same place that their
      // initial PointerDownEvent was, we want to re-use the path we found when
      // the pointer went down, rather than do hit detection each time we get
      // such an event.
      hitTestResult = _hitTests[event.pointer];
    }
    assert(() {
      if (debugPrintMouseHoverEvents && event is PointerHoverEvent) {
        debugPrint('$event');
      }
      return true;
    }());
    if (hitTestResult != null ||
        event is PointerHoverEvent ||
        event is PointerAddedEvent ||
        event is PointerRemovedEvent) {
      dispatchEvent(event, hitTestResult);
    }
  }
}
