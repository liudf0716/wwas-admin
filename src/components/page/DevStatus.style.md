# DevStatus 样式配置说明

## 文件说明
- **DevStatus.vue**: 主组件文件，包含模板和脚本
- **DevStatus.css**: 独立的样式文件，包含所有组件样式

## 样式结构

### 1. 基础布局样式
- `.rad-group`: 单选按钮组间距
- `.handle-box2`: 右侧搜索框布局
- `.orange`: 橙色主题色

### 2. 表格操作按钮样式
- `.action-buttons`: 操作按钮容器
- `.action-btn-circle`: 圆形操作按钮
- `.action-btn-disabled`: 禁用状态样式

### 3. 下拉菜单样式
- `.action-dropdown-menu`: 下拉菜单容器
- `.dropdown-item-with-icon`: 带图标的下拉项
- `.danger-item`: 危险操作样式（如重启）

### 4. 对话框样式
- `.dialog-content`: 对话框内容布局
- `.dialog-section`: 对话框区块样式

### 5. 无线设置专用样式
- `.wireless-section`: 无线设置区域
- `.settings-card`: 设置卡片样式

### 6. 表单和输入框样式
- `.el-input__inner`: 输入框增强样式
- `.wireless-icon`: 无线图标样式

## 主题色配置

### 主要颜色
- **主色调**: `#409eff` (蓝色)
- **成功色**: `#67c23a` (绿色)  
- **警告色**: `#e6a23c` (橙色)
- **危险色**: `#f56c6c` (红色)
- **信息色**: `#909399` (灰色)

### 背景色
- **卡片背景**: `#fff` (白色)
- **悬停背景**: `#f5f7fa` (浅灰)
- **渐变背景**: `linear-gradient(135deg, #f0f9ff 0%, #e6f7ff 100%)`

## 自定义主题指南

### 1. 修改主色调
在CSS文件中搜索 `#409eff` 并替换为新的主色调。

### 2. 修改按钮样式
- 圆形按钮大小：修改 `.action-btn-circle` 的 `width` 和 `height`
- 悬停效果：修改 `:hover` 伪类的 `transform` 和 `box-shadow`

### 3. 修改卡片样式
- 圆角大小：修改 `border-radius` 属性
- 阴影效果：修改 `box-shadow` 属性

### 4. 修改间距
- 按钮间距：修改 `.action-buttons` 的 `gap` 属性
- 卡片间距：修改各个 `margin` 和 `padding` 属性

## 响应式设计注意事项

当前样式主要为桌面端设计，如需支持移动端，建议添加：

```css
@media (max-width: 768px) {
  .action-btn-circle {
    width: 28px !important;
    height: 28px !important;
  }
  
  .action-dropdown-menu {
    min-width: 140px !important;
  }
}
```

## 维护建议

1. **保持样式模块化**: 相关样式归类在一起
2. **使用语义化类名**: 类名应该表达功能而非样式
3. **避免内联样式**: 尽量将样式写在CSS文件中
4. **文档更新**: 修改样式时更新此文档
