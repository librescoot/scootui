import 'package:github/github.dart';

class DownloadableRelease {
  final String name;
  final List<DownloadableTiles> tiles;

  DownloadableRelease(this.name, this.tiles);
}

class DownloadableTiles {
  final String name;
  final String url;

  DownloadableTiles(this.name, this.url);
}

class TilesUpdateRepository {
  final GitHub _gitHub;

  TilesUpdateRepository() : _gitHub = GitHub();

  Future<List<DownloadableRelease>> getReleases() async {
    final releases = await _gitHub.repositories
        .listReleases(RepositorySlug("librescoot", "osm-tiles"))
        .toList();

    return releases
        .map((release) => DownloadableRelease(
            release.name ?? 'Unknown',
            release.assets
                    ?.map((asset) => DownloadableTiles(asset.name ?? 'Unknown',
                        asset.browserDownloadUrl ?? ''))
                    .toList() ??
                []))
        .toList();
  }
}
