// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_dev/search/search_form.dart';
import 'package:test/test.dart';

void main() {
  group('SearchForm', () {
    test('query with defaults', () {
      final form = SearchForm(query: 'web framework');
      expect(form.toSearchLink(), '/packages?q=web+framework');
      expect(form.toSearchLink(page: 1), '/packages?q=web+framework');
      expect(form.toSearchLink(page: 2), '/packages?q=web+framework&page=2');
    });

    test('query with defaults on page 1', () {
      final form = SearchForm(query: 'web framework', currentPage: 1);
      expect(form.toSearchLink(), '/packages?q=web+framework');
      expect(form.toSearchLink(page: 1), '/packages?q=web+framework');
      expect(form.toSearchLink(page: 2), '/packages?q=web+framework&page=2');
    });

    test('query with defaults on page 3', () {
      final form = SearchForm(query: 'web framework', currentPage: 3);
      expect(form.toSearchLink(), '/packages?q=web+framework&page=3');
      expect(form.toSearchLink(page: 1), '/packages?q=web+framework');
      expect(form.toSearchLink(page: 2), '/packages?q=web+framework&page=2');
      expect(form.toSearchLink(page: 3), '/packages?q=web+framework&page=3');
    });

    test('query with with sdk context', () {
      final form = SearchForm(query: 'sdk:flutter some framework');
      expect(form.toSearchLink(), '/packages?q=sdk%3Aflutter+some+framework');
      expect(form.toSearchLink(page: 1),
          '/packages?q=sdk%3Aflutter+some+framework');
      expect(form.toSearchLink(page: 2),
          '/packages?q=sdk%3Aflutter+some+framework&page=2');
    });

    test('query with with a single sdk parameter', () {
      final form = SearchForm.parse(SearchContext.regular(), {
        'q': 'sdk:dart some framework',
      });
      // pages
      expect(form.toSearchLink(), '/packages?q=sdk%3Adart+some+framework');
      expect(form.toSearchLink(page: 1), form.toSearchLink());
      expect(form.toSearchLink(page: 2),
          '/packages?q=sdk%3Adart+some+framework&page=2');
      // toggle
      expect(form.toggleRequiredTag('sdk:flutter').toSearchLink(),
          '/packages?q=sdk%3Adart+sdk%3Aflutter+some+framework');
      expect(form.toggleRequiredTag('sdk:dart').toSearchLink(),
          '/packages?q=some+framework');
      // query parameters
      expect(form.parsedQuery.tagsPredicate.toQueryParameters(), ['sdk:dart']);
      expect(
        form.toServiceQuery().toUriQueryParameters(),
        {
          'q': 'sdk:dart some framework',
          'tags': [
            '-is:discontinued',
            '-is:unlisted',
            '-is:legacy',
          ],
          'offset': '0',
          'limit': '10',
        },
      );
    });

    test('non-standard sdk query parameters', () {
      expect(
        SearchForm.parse(
          SearchContext.regular(),
          {'q': 'sdk:any'},
        ).parsedQuery.tagsPredicate.toQueryParameters(),
        ['sdk:any'],
      );
    });

    test('query-based show:hidden', () {
      expect(
        SearchForm(query: 'show:hidden')
            .toServiceQuery()
            .toUriQueryParameters()['tags'],
        [],
      );
    });

    test('query-based discontinued', () {
      expect(
        SearchForm(query: 'is:discontinued')
            .toServiceQuery()
            .toUriQueryParameters()['tags'],
        ['-is:unlisted', '-is:legacy'],
      );
      expect(
        SearchForm(query: 'show:discontinued')
            .toServiceQuery()
            .toUriQueryParameters()['tags'],
        ['-is:unlisted', '-is:legacy'],
      );
    });

    test('query with license tag', () {
      final form = SearchForm(query: 'license:gpl some framework');
      expect(form.toSearchLink(), '/packages?q=license%3Agpl+some+framework');
      expect(form.parsedQuery.text, 'some framework');
      expect(
          form.parsedQuery.tagsPredicate.toQueryParameters(), ['license:gpl']);
    });

    test('query-based unlisted', () {
      expect(
        SearchForm(query: 'is:unlisted')
            .toServiceQuery()
            .toUriQueryParameters()['tags'],
        ['-is:discontinued', '-is:legacy'],
      );
      expect(
        SearchForm(query: 'show:unlisted')
            .toServiceQuery()
            .toUriQueryParameters()['tags'],
        ['-is:discontinued', '-is:legacy'],
      );
    });

    test('query-based legacy', () {
      expect(
        SearchForm(query: 'is:legacy')
            .toServiceQuery()
            .toUriQueryParameters()['tags'],
        ['-is:discontinued', '-is:unlisted'],
      );
      expect(
        SearchForm(query: 'show:legacy')
            .toServiceQuery()
            .toUriQueryParameters()['tags'],
        ['-is:discontinued', '-is:unlisted'],
      );
    });
  });
}
