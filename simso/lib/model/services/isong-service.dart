import 'package:simso/model/entities/song-model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'isong-service.dart';

class SongService extends ISongService {
  @override
  Future<String> addSong(SongModel song) async {
    // save it from firestore instance
    // collection name is Song.SONG_COLLECTION
    // add function after serialized data
    // returns document reference type
    DocumentReference ref = await Firestore.instance
        .collection(SongModel.SONG_COLLECTION)
        .add(song.serialize());
    return ref.documentID;
  }

  @override
  Future<List<SongModel>> getSong(String email) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(SongModel.SONG_COLLECTION)
        .where(SongModel.CREATEDBY, isEqualTo: email)
        .getDocuments();
    var songlist = <SongModel>[];
    if (querySnapshot == null || querySnapshot.documents.length == 0) {
      return songlist;
    }

    for (DocumentSnapshot doc in querySnapshot.documents) {
      songlist.add(SongModel.deserialize(doc.data, doc.documentID));
    }
    return songlist;
  }

  @override
  Future<void> updateSongURL(String songURL, SongModel song) async {
    await Firestore.instance
        .collection(SongModel.SONG_COLLECTION)
        .document(song.songId)
        //.setData(user.serialize()
        .updateData({'songURL': songURL}).then((val) {
      print('SongURL Updated');
    }).catchError((e) {
      print(e);
    }); // serialized for keymap val, if user exist, corresponding user updated
  }

  @override
  Future<void> updateSong(SongModel song) async {
    await Firestore.instance
        .collection(SongModel.SONG_COLLECTION)
        .document(song.songId)
        .setData(song
            .serialize()); // serialized for keymap val, if book exist, corresponding book updated
  }
}
