import Prelude

extension GraphBacking {
  internal static let template = GraphBacking(
    errorReason: nil,
    project: nil,
    status: GraphBacking.Status.collected
  )

  internal static let errored = GraphBacking.template
    |> \.status .~ GraphBacking.Status.errored
    |> \.errorReason .~ "Credit card expired."
    |> \.project .~ .template
}

extension GraphBacking.Project {
  internal static let template = GraphBacking.Project(
    finalCollectionDate: "2019-11-29T15:15:05Z",
    id: "1",
    name: "Cool project",
    slug: "/cool-project"
  )
}
