
class LovedPlaylistIdsHolder {
  final ids = <int>[];

  void add(int id) {
    if (!ids.contains(id)) {
      ids.add(id);
    }
  }

  void remove(int id) {
    ids.remove(id);
  }

  void update(List<int> ids) {
    this.ids.clear();
    this.ids.addAll(ids);
  }

  bool exists(int id) {
    return ids.contains(id);
  }
}