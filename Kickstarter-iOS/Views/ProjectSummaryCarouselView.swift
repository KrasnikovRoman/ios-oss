import Foundation
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

  func configure(with items: [ProjectSummaryItem]) {
    self.viewModel.inputs.configure(with: items)
  }

  // MARK: - Configuration

  private func configureViews() {
    self.addSubview(self.collectionView)

    self.collectionView.register(
      ProjectSummaryCarouselCell.self,
      forCellWithReuseIdentifier: ProjectSummaryCarouselCell.defaultReusableId
    )
  }

  private func setupConstraints() {
    _ = (self.collectionView, self)
      |> ksr_constrainViewToEdgesInParent()

    self.collectionViewHeightConstraint = self.collectionView.heightAnchor.constraint(equalToConstant: 0)
    self.collectionViewHeightConstraint?.priority = .defaultLow
    self.collectionViewHeightConstraint?.isActive = true
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
        self.collectionViewHeightConstraint?.constant = self.dataSource.greatestCombinedTextHeight
      }
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
      width: UIScreen.main.bounds.width / 2,
      height: self.dataSource.greatestCombinedTextHeight
    )
  }
}
