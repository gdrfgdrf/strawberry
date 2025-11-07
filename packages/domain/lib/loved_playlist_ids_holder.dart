
class LovedPlaylistIdsHolder {
  final ids = <int>[];

  void update(List<int> ids) {
    this.ids.clear();
    this.ids.addAll(ids);
  }

  bool exists(int id) {
    return ids.contains(id);
  }
}