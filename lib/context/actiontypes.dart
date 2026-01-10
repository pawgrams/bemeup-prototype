// Datei: context\actiontypes.dart
import 'prices.dart';

Map<String, dynamic> getActionTypes() {
  return {
    'suggest':    {'song': '', 'artist': 0, 'title': '', 'version': '', 'genre': '', 'credits': 0, 'timestamp': 0, 'user': ''},
    'vote':       {'stage': '', 'song': '', 'timestamp': 0, 'credits': prices['boost']?['vote'] ?? 0, 'user': ''},
    'spotlight':  {'stage': '', 'song': '', 'timestamp': 0, 'credits': prices['boost']?['spotlight'] ?? 0, 'user': ''},
    'highlight':  {'song': '', 'timestamp': 0, 'credits': prices['boost']?['highlight'] ?? 0, 'user': ''},
    'follow':     {'targetuser': '', 'credits': 0, 'timestamp': 0, 'user': ''},
    'unfollow':   {'targetuser': '', 'credits': 0, 'timestamp': 0, 'user': ''},
    'like':       {'song': '', 'credits': 0, 'timestamp': 0, 'user': ''},
    'unlike':     {'song': '', 'credits': 0, 'timestamp': 0, 'user': ''},
    'newsong':    {'genre': '', 'stile': 0, 'voice': '', 'language': '', 'lyrics': '', 'credits': 0, 'timestamp': 0, 'user': ''},
  };
}

// to be added
  // updatename
  // checkname
  // newavatar
  // newbg
  // newlyrics
  // newstyle
  // newplaylist
  // addtoplaylist
  // topup
  // newplan
  // newbio
  // newlink
  // newevent
  // updateevent
  // newstage
  // updatestage
  // eventlike
  // evenunline
  // newticket
  // newfungible
  // newcollectible
  // newpresalebuy
  // newnftbuy
  // newnftsell
  // updatewalletaddress
  // ...


