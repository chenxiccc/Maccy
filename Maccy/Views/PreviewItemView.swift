import KeyboardShortcuts
import SwiftUI

// 仅在有图片预览尺寸时设置 frame，文字预览保持原始行为
// Only apply frame when image preview size is available, keep original behavior for text
private struct OptionalFrameModifier: ViewModifier {
  var size: CGSize?

  func body(content: Content) -> some View {
    if let size = size {
      content.frame(width: size.width, height: size.height)
    } else {
      content
    }
  }
}

struct PreviewItemView: View {
  weak var item: HistoryItemDecorator?
  // 可用的预览空间（由 HistoryItemView 传入）
  // Available preview space (passed from HistoryItemView)
  var availableSize: CGSize = CGSize(width: 400, height: 600)

  // 预览中非图片区域的估算高度（元数据、快捷键提示等）
  // Estimated height for non-image area (metadata, shortcuts, etc.)
  private let metadataHeight: CGFloat = 150
  private let contentPadding: CGFloat = 0
  // 元数据文字至少需要的宽度 / Minimum width for metadata text
  private let minContentWidth: CGFloat = 250

  // 根据图片尺寸和可用空间计算最优预览尺寸
  // Compute optimal preview size based on image dimensions and available space
  private var imagePreviewSize: CGSize? {
    guard let item = item, let image = item.previewImage else { return nil }
    let imgSize = image.size
    guard imgSize.width > 0 && imgSize.height > 0 else { return nil }

    let maxImageWidth = availableSize.width - contentPadding
    let maxImageHeight = availableSize.height - metadataHeight - contentPadding

    // 等比缩放，不放大 / Scale proportionally, don't upscale
    let scaleX = min(1.0, maxImageWidth / imgSize.width)
    let scaleY = min(1.0, maxImageHeight / imgSize.height)
    let scale = min(scaleX, scaleY)

    let displayWidth = imgSize.width * scale
    let displayHeight = imgSize.height * scale

    let popoverWidth = max(minContentWidth, displayWidth + contentPadding)
    let popoverHeight = displayHeight + metadataHeight + contentPadding

    return CGSize(
      width: min(popoverWidth, availableSize.width),
      height: min(popoverHeight, availableSize.height)
    )
  }

  var body: some View {
    if let item = item {
      VStack(alignment: .leading, spacing: 0) {
        if let image = item.previewImage {
          Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            // 限制最大尺寸为原始图片尺寸，防止小图被拉伸
            // Limit max size to original image size to prevent upscaling
            .frame(maxWidth: image.size.width, maxHeight: image.size.height)
            .clipShape(.rect(cornerRadius: 5))
        } else {
          ScrollView {
            WrappingTextView {
              Text(item.text)
                .font(.body)
            }
          }
        }

        Divider()
          .padding(.vertical)

        if let application = item.application {
          HStack(spacing: 3) {
            Text("Application", tableName: "PreviewItemView")
            Image(nsImage: item.applicationImage.nsImage)
              .resizable()
              .frame(width: 11, height: 11)
            Text(application)
          }
        }

        HStack(spacing: 3) {
          Text("FirstCopyTime", tableName: "PreviewItemView")
          Text(item.item.firstCopiedAt, style: .date)
          Text(item.item.firstCopiedAt, style: .time)
        }

        HStack(spacing: 3) {
          Text("LastCopyTime", tableName: "PreviewItemView")
          Text(item.item.lastCopiedAt, style: .date)
          Text(item.item.lastCopiedAt, style: .time)
        }

        HStack(spacing: 3) {
          Text("NumberOfCopies", tableName: "PreviewItemView")
          Text(String(item.item.numberOfCopies))
        }
        .padding(.bottom)

        if let pinKey = KeyboardShortcuts.Shortcut(name: .pin) {
          Text(
            NSLocalizedString("PinKey", tableName: "PreviewItemView", comment: "")
              .replacingOccurrences(of: "{pinKey}", with: pinKey.description)
          )
        }

        if let deleteKey = KeyboardShortcuts.Shortcut(name: .delete) {
          Text(
            NSLocalizedString("DeleteKey", tableName: "PreviewItemView", comment: "")
              .replacingOccurrences(of: "{deleteKey}", with: deleteKey.description)
          )
        }
      }
      .controlSize(.small)
      .modifier(OptionalFrameModifier(size: imagePreviewSize))
      .padding()
    }
  }
}
