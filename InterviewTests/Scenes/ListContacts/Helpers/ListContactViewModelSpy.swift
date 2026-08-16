//
//  ListContactViewModelSpy.swift
//  Interview
//
//  Created by Thiago Monteiro on 8/16/26.
//  Copyright © 2026 PicPay. All rights reserved.
//

import Interview

final class ListContactViewModelSpy: ListcontactResultLoader {
    var expected: ContactResult?

    private(set) var loadMoviesCalled: Bool = false
    private(set) var loadMoviesCount: Int = 0

    func loadMovies() async throws -> ContactResult {
        loadMoviesCalled = true
        loadMoviesCount += 1
        return expected ?? .failure(.invalidData)
    }
}
