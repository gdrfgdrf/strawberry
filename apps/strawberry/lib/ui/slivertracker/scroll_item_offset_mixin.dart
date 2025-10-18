import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 计算滑动元素的曝光范围
mixin ScrollItemOffsetMixin {
  // 滑块起始位置距离视窗起始位置的距离
  double? itemStartOffset;

  // itemStartOffset + 滑块长度
  double? itemEndOffset;

  // 与视窗切割
  double? itemStartOffsetClamp;
  double? itemEndOffsetClamp;
  double? paintExtent;

  void calculateDisplayPercent(
    BuildContext context,
    double topOverlapCompensation,
    double bottomOverlapCompensation,
  ) {
    // RenderSliverList
    RenderSliverMultiBoxAdaptor? renderSliverMultiBoxAdaptor =
        context.findAncestorRenderObjectOfType<RenderSliverMultiBoxAdaptor>();
    if (renderSliverMultiBoxAdaptor == null) {
      paintExtent = 0;
      return;
    }
    final geometry = renderSliverMultiBoxAdaptor.geometry;
    if (geometry == null) {
      paintExtent = 0;
      return;
    }

    // ScrollView的起始绘制位置
    double startOffset = renderSliverMultiBoxAdaptor.constraints.scrollOffset;
    // ScrollView的结束绘制位置
    double endOffset = startOffset + geometry.paintExtent;
    // 主轴方向
    Axis axis = renderSliverMultiBoxAdaptor.constraints.axis;
    paintExtent = geometry.paintExtent;

    // 如果还没有显示到Viewport中
    if (endOffset < 0.00001) {
      paintExtent = 0;
      return;
    }

    // 当前item相对于列表起始位置的偏移 SliverLogicalParentData
    context.visitAncestorElements((element) {
      final renderObject = element.renderObject;
      if (renderObject == null) {
        return true;
      }

      if (renderObject.parentData == null) {
        return true;
      }

      if (renderObject.parentData is! SliverLogicalParentData) {
        return true;
      }

      final tempItemStartOffset =
          (element.renderObject!.parentData as SliverLogicalParentData)
              .layoutOffset;
      if (tempItemStartOffset == null) {
        return true;
      }

      final itemSize = (element.renderObject as RenderBox).size;

      itemStartOffset = tempItemStartOffset;
      itemEndOffset =
          axis == Axis.vertical
              ? itemStartOffset! + itemSize.height
              : itemStartOffset! + itemSize.width;
      itemStartOffsetClamp = itemStartOffset!.clamp(
        startOffset + topOverlapCompensation,
        endOffset - bottomOverlapCompensation,
      );
      itemEndOffsetClamp = itemEndOffset!.clamp(
        startOffset + topOverlapCompensation,
        endOffset - bottomOverlapCompensation,
      );

      return false;
    });
  }
}
