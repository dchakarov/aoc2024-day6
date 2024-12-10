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
    
    var startingCell = (0, 0)
    
    for i in 0..<grid.count {
        for j in 0..<grid.count {
            if grid[i][j] == "^" {
                startingCell = (i, j)
                break
            }
        }
    }
    
    // Part 1
    
    let visitedCells = try! getVisitedCells(startingCell: startingCell, grid: grid)
    print(visitedCells.count)
    
    // Part 2

    let visitedCellsExcludingStartingCell = visitedCells.filter { $0 != startingCell }
    var loopCount = 0
    var blockedCellsCount = 0
    for cell in visitedCellsExcludingStartingCell {
        var tempGrid = grid
        tempGrid[cell.0][cell.1] = "#"
        blockedCellsCount += 1
        if blockedCellsCount % 100 == 0 {
            print(blockedCellsCount)
        }
        do {
            try getVisitedCells1(startingCell: startingCell, grid: tempGrid)
        } catch {
            loopCount += 1
        }
    }
    
    print(loopCount)
}

func getVisitedCells(startingCell: (Int, Int), grid: [[Character]]) throws -> [(Int, Int)] {
    var visitedCells = [(Int, Int)]()
    visitedCells.append(startingCell)
    var currentCell = startingCell
    var currentDirection = Direction.up
    var stillInsideGrid = true
    var startingCellDirections: [Direction] = [.up]
    
    while stillInsideGrid {
        let step = currentDirection.move()
        let nextCell = (currentCell.0 + step.0, currentCell.1 + step.1)
        if nextCell.0 < 0 || nextCell.1 < 0 || nextCell.0 >= grid.count || nextCell.1 >= grid.count {
            stillInsideGrid = false
        } else {
            switch grid[nextCell.0][nextCell.1] {
            case "#":
                currentDirection = currentDirection.next()
            case ".":
                visitedCells.append(nextCell)
                currentCell = nextCell
            case "^":
                if startingCellDirections.contains(currentDirection) {
                    throw LoopError.loopDetected
                } else {
                    visitedCells.append(nextCell)
                    currentCell = nextCell
                    startingCellDirections.append(currentDirection)
                }
            default: fatalError()
            }
        }
    }
    
    
    return visitedCells.enumerated().filter { (index, element) in
        visitedCells.firstIndex(where: { $0 == element }) == index
    }.map { $0.element }
}

func getVisitedCells1(startingCell: (Int, Int), grid: [[Character]]) throws -> [(Int, Int)] {
    var visitedCells = [(Int, Int)]()
    visitedCells.append(startingCell)
    var currentCell = startingCell
    var currentDirection = Direction.up
    var stillInsideGrid = true
    var cellDirections: [String: [Direction]] = ["\(startingCell)": [.up]]
    
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
                if let cd = cellDirections["\(nextCell)"], cd.contains(currentDirection) {
                    throw LoopError.loopDetected
                } else {
                    visitedCells.append(nextCell)
                    currentCell = nextCell
                    if cellDirections["\(nextCell)"] != nil {
                        cellDirections["\(nextCell)"]!.append(currentDirection)
                    } else {
                        cellDirections["\(nextCell)"] = [currentDirection]
                    }
                }
            default: fatalError()
            }
        }
    }
    
    
    return visitedCells.enumerated().filter { (index, element) in
        visitedCells.firstIndex(where: { $0 == element }) == index
    }.map { $0.element }
}

enum LoopError: Error {
    case loopDetected
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
