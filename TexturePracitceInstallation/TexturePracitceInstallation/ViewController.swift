//
//  ViewController.swift
//  TexturePracitceInstallation
//
//  Created by minhoi_goo on 27/06/2019.
//  Copyright © 2019 minhoi_goo. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class ViewController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate {

  struct State {
    var itemCount: Int
    var fetchingMore: Bool
    static let empty = State(itemCount: 20, fetchingMore: false)
  }

  enum Action {
    case beginBatchFetch
    case endBatchFetch(resultCount: Int)
  }

  var tableNode: ASTableNode {
    return node as! ASTableNode
  }

  fileprivate(set) var state: State = .empty

  init() {
    super.init(node: ASTableNode())
    tableNode.delegate = self
    tableNode.dataSource = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("storyboards are incompatible with truth and beauty")
  }

  // MARK:- ASTableNode data source and delegate

  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    let rowCount = self.tableNode(tableNode, numberOfRowsInSection: 0)

    if state.fetchingMore && indexPath.row == rowCount - 1 {
      let node = TailLoadingCellNode()
      node.style.height = ASDimensionMake(44.0)
      return node;
    }

    let node = ASTextCellNode()
    node.text = String(format: "[%ld.%ld] says hello!", indexPath.section, indexPath.row)
    return node
  }

  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return 1
  }

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    var count = state.itemCount
    if state.fetchingMore {
      count += 1
    }
    return count
  }

  func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
    DispatchQueue.main.async {
      let oldState = self.state
      self.state = ViewController.handleAction(.beginBatchFetch, fromState: oldState)
      self.renderDiff(oldState)
    }

    ViewController.fetchDataWithCompletion { resultCount in
      let action = Action.endBatchFetch(resultCount: resultCount)
      let oldState = self.state
      self.state = ViewController.handleAction(action, fromState: oldState)
      self.renderDiff(oldState)
      context.completeBatchFetching(true)
    }
  }

  fileprivate func renderDiff(_ oldState: State) {
    self.tableNode.performBatchUpdates({
      // Add or remove items
      let rowCountCharge = state.itemCount - oldState.itemCount
      if rowCountCharge > 0 {
        let indexPaths = (oldState.itemCount..<state.itemCount).map { index in
          IndexPath(row: index, section: 0)
        }
        tableNode.insertRows(at: indexPaths, with: .none)
      } else if rowCountCharge < 0 {
        assertionFailure("Deleting rows is not implemented. YAGNI.")
      }

      // Add or remove spinner
      if state.fetchingMore != oldState.fetchingMore {
        if state.fetchingMore {
          // Add spinner
          let spinnerIndexPath = IndexPath(row: state.itemCount, section: 0)
          tableNode.insertRows(at: [spinnerIndexPath], with: .none)
        } else {
          // Remove spinner
          let spinnerIndexPath = IndexPath(row: oldState.itemCount, section: 0)
          tableNode.deleteRows(at: [spinnerIndexPath], with: .none)
        }
      }
    }, completion: nil)
  }

  fileprivate static func fetchDataWithCompletion(_ completion: @escaping (Int) -> Void) {
    let time = DispatchTime.now() + Double(Int64(TimeInterval(NSEC_PER_SEC) * 1.0)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
      let resultCount = Int(arc4random_uniform(20))
      completion(resultCount)
    }
  }

  fileprivate static func handleAction(_ action: Action, fromState state: State) -> State {
    var state = state
    switch action {
    case .beginBatchFetch:
      state.fetchingMore = true
    case let .endBatchFetch(resultCount):
      state.itemCount += resultCount
      state.fetchingMore = false
    }
    return state
  }
}


