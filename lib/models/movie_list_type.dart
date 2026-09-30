enum MovieListType {
  favorites,
  watched,
  watching,
  wantToWatch,
}

extension MovieListTypeX on MovieListType {
  String get firestoreName {
    switch (this) {
      case MovieListType.favorites:
        return 'favorites';
      case MovieListType.watched:
        return 'watched';
      case MovieListType.watching:
        return 'watching';
      case MovieListType.wantToWatch:
        return 'want_to_watch';
    }
  }

  String get title {
    switch (this) {
      case MovieListType.favorites:
        return 'Favorites';
      case MovieListType.watched:
        return 'Watched';
      case MovieListType.watching:
        return 'Watching';
      case MovieListType.wantToWatch:
        return 'Want to Watch';
    }
  }

  String get emptyMessage {
    switch (this) {
      case MovieListType.favorites:
        return 'No favorite movies yet.';
      case MovieListType.watched:
        return 'No watched movies yet.';
      case MovieListType.watching:
        return 'You are not watching anything yet.';
      case MovieListType.wantToWatch:
        return 'Your watch list is empty.';
    }
  }
}
