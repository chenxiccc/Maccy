import Defaults
import SwiftUI

struct HistoryItemView: View {
  @Bindable var item: HistoryItemDecorator

  @Environment(AppState.self) private var appState

  // 计算预览弹窗应显示在哪一侧
  // Compute preferred popover edge based on available screen space
  private var preferredPopoverEdge: Edge {
    guard let panel = appState.appDelegate?.panel,
          let screen = panel.screen?.visibleFrame else {
      return .trailing
    }
    let spaceOnRight = screen.maxX - panel.frame.maxX
    let spaceOnLeft = panel.frame.minX - screen.minX
    return spaceOnLeft > spaceOnRight ? .leading : .trailing
  }

  // 计算预览弹窗可用的最大尺寸
  // Compute maximum available size for the popover
  private var availablePreviewSize: CGSize {
    guard let panel = appState.appDelegate?.panel,
          let screen = panel.screen?.visibleFrame else {
      return CGSize(width: 400, height: 600)
    }
    let edge = preferredPopoverEdge
    // 预留 popover 箭头 + 内部 padding + VStack padding 的空间
    // Reserve space for popover arrow + internal padding + VStack padding
    let popoverChrome: CGFloat = 80
    let availableWidth: CGFloat
    if edge == .trailing {
      availableWidth = screen.maxX - panel.frame.maxX - popoverChrome
    } else {
      availableWidth = panel.frame.minX - screen.minX - popoverChrome
    }
    let availableHeight = min(panel.frame.height, screen.height) - 20
    return CGSize(
      width: max(250, availableWidth),
      height: max(200, availableHeight)
    )
  }

  var body: some View {
    ListItemView(
      id: item.id,
      appIcon: item.applicationImage,
      image: item.thumbnailImage,
      accessoryImage: item.thumbnailImage != nil ? nil : ColorImage.from(item.title),
      attributedTitle: item.attributedTitle,
      shortcuts: item.shortcuts,
      isSelected: item.isSelected
    ) {
      Text(verbatim: item.title)
    }
    .onAppear {
      item.ensureThumbnailImage()
    }
    .onTapGesture {
      appState.history.select(item)
    }
    .popover(isPresented: $item.showPreview, arrowEdge: preferredPopoverEdge) {
      PreviewItemView(item: item, availableSize: availablePreviewSize)
        .onAppear {
          item.ensurePreviewImage()
        }
    }
  }
}
