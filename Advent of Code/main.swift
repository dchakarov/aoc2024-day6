//
//  main.swift
//  No rights reserved.
//

import Foundation
import RegexHelper

func main() {
    let fileUrl = URL(fileURLWithPath: "./aoc-input")
    guard let inputString = try? String(contentsOf: fileUrl, encoding: .utf8) else { fatalError("Invalid input") }
    
    let lines = inputString.components(separatedBy: "\n")
        .filter { !$0.isEmpty }

    var grid = [[Character]]()
    
    lines.forEach { line in
        grid.append(Array(line))
    }
    
    var visitedCells = [(Int, Int)]()
    var currentCell = (0, 0)
    
    for i in 0..<grid.count {
        for j in 0..<grid.count {
            if grid[i][j] == "^" {
                visitedCells.append((i, j))
                currentCell = (i, j)
                break
            }
        }
    }
    
    var currentDirection = Direction.up
    var stillInsideGrid = true
    
    while stillInsideGrid {
        let step = currentDirection.move()
        let nextCell = (currentCell.0 + step.0, currentCell.1 + step.1)
        if nextCell.0 < 0 || nextCell.1 < 0 || nextCell.0 >= grid.count || nextCell.1 >= grid.count {
            stillInsideGrid = false
        } else {
            switch grid[nextCell.0][nextCell.1] {
            case "#":
                currentDirection = currentDirection.next()
            case ".", "^":
                visitedCells.append(nextCell)
                currentCell = nextCell
            default: fatalError()
            }
        }
    }
    
    
    let uniqueVisitedCells = visitedCells.enumerated().filter { (index, element) in
        visitedCells.firstIndex(where: { $0 == element }) == index
    }.map { $0.element }

    print(uniqueVisitedCells.count)
}

enum Direction {
    case up
    case right
    case down
    case left
    
    func next() -> Direction {
        switch self {
        case .up: return .right
        case .right: return .down
        case .down: return .left
        case .left: return .up
        }
    }
    
    func move() -> (Int, Int) {
        switch self {
        case .up: return (-1, 0)
        case .right: return (0, 1)
        case .down: return (1, 0)
        case .left: return (0, -1)
        }
    }
}


main()
