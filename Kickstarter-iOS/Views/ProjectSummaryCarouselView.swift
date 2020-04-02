import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class ProjectSummaryCarouselView: UIView {
  // MARK: - Properties

  private lazy var collectionView: UICollectionView = {
    UICollectionView(frame: .zero, collectionViewLayout: self.layout)
      |> \.alwaysBounceHorizontal .~ true
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self
      |> \.showsHorizontalScrollIndicator .~ false
  }()

  private var collectionViewHeightConstraint: NSLayoutConstraint?

  private var greatestCombinedTextHeight: CGFloat = 0

  private let dataSource = ProjectSummaryCarouselDataSource()

  private let layout: UICollectionViewFlowLayout = {
    UICollectionViewFlowLayout()
      |> \.minimumInteritemSpacing .~ Styles.grid(2)
      |> \.sectionInset .~ .init(leftRight: Styles.grid(4))
      |> \.scrollDirection .~ .horizontal
  }()

  private let viewModel: ProjectSummaryCarouselViewModelType = ProjectSummaryCarouselViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Accessors

  func configure(with items: [ProjectSummaryEnvelope.ProjectSummaryItem]) {
    self.viewModel.inputs.configure(with: items)
  }

  // MARK: - Configuration

  private func configureViews() {
    self.addSubview(self.collectionView)

    self.collectionView.register(ProjectSummaryCarouselCell.self)
  }

  private func setupConstraints() {
    _ = (self.collectionView, self)
      |> ksr_constrainViewToEdgesInParent()

    self.collectionViewHeightConstraint = self.collectionView.heightAnchor.constraint(equalToConstant: 0)
      |> \.priority .~ .defaultLow
      |> \.isActive .~ true
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadProjectSummaryItemsIntoDataSource
      .observeForUI()
      .observeValues { [weak self] items in
        guard let self = self else { return }

        self.dataSource.load(items)
        self.collectionView.reloadData()
        self.updateGreatestCombinedTextHeight(with: items)
        self.updateCollectionViewHeight()
      }
  }

  private func updateGreatestCombinedTextHeight(with items: [ProjectSummaryEnvelope.ProjectSummaryItem]) {
    self.greatestCombinedTextHeight = greatestCombinedTextHeightForItems(items)
  }

  private func updateCollectionViewHeight() {
    self.collectionViewHeightConstraint?.constant = self.greatestCombinedTextHeight
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.collectionView
      |> \.backgroundColor .~ .white
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProjectSummaryCarouselView: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    sizeForItemAt _: IndexPath
  ) -> CGSize {
    return CGSize(
      width: ProjectSummaryCarouselCell.Layout.MaxOuterWidth.size,
      height: self.greatestCombinedTextHeight
    )
  }
}

private func greatestCombinedTextHeightForItems(
  _ items: [ProjectSummaryEnvelope.ProjectSummaryItem]
) -> CGFloat {
  return items.reduce(0) { (current, item) -> CGFloat in
    let size = CGSize(
      width: ProjectSummaryCarouselCell.Layout.MaxInnerWidth.size,
      height: .greatestFiniteMagnitude
    )

    // TODO: use correct translation here once available
    let titleHeight = (item.question.rawValue as NSString).boundingRect(
      with: size,
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      attributes: [.font: ProjectSummaryCarouselCell.Style.Title.font()],
      context: nil
    )
    .height

    let bodyHeight = (item.response as NSString).boundingRect(
      with: size,
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      attributes: [.font: ProjectSummaryCarouselCell.Style.Body.font()],
      context: nil
    )
    .height

    let totalHeight = ProjectSummaryCarouselCell.Layout.Margin.width * 2
      + ProjectSummaryCarouselCell.Layout.Spacing.width
      + ceil(titleHeight)
      + ceil(bodyHeight)

    return max(current, totalHeight)
  }
}
