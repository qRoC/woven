import 'package:polymer/polymer.dart';
import 'package:firebase/firebase.dart' as db;
import 'dart:html';
import 'dart:async';
import 'package:woven/src/shared/input_formatter.dart';
import 'package:woven/src/client/app.dart';
import 'package:core_elements/core_pages.dart';
import 'package:woven/config/config.dart';
import 'package:woven/src/client/view_model/feed.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:woven/src/client/infinite_scroll.dart';
import 'package:core_elements/core_header_panel.dart';

/**
 * A list of items.
 */
@CustomTag('inbox-list')
class InboxList extends PolymerElement with Observable {
  @published App app;
  @published FeedViewModel viewModel;

  List<StreamSubscription> subscriptions;

  InboxList.created() : super.created();

  InputElement get subject => $['subject'];

  void selectItem(Event e, var detail, Element target) {
    // Look in the items list for the item that matches the
    // id passed in the data-id attribute on the element.
    var item = viewModel.items.firstWhere((i) => i['id'] == target.dataset['id']);

    app.selectedItem = item;
    app.selectedPage = 1;
    app.userCameFromInbox = true;

    var str = target.dataset['id'];
    var bytes = UTF8.encode(str);
    var base64 = CryptoUtils.bytesToBase64(bytes);

    app.router.dispatch(url: "/item/$base64");
  }

  toggleLike(Event e, var detail, Element target) {
    e.stopPropagation();

//    if (target.classes.contains("selected")) {
//      target.classes.remove("clicked");
//    } else {
//      target.classes.add("clicked");
//    }

    viewModel.toggleItemLike(target.dataset['id']);
  }

  toggleStar(Event e, var detail, Element target) {
    e.stopPropagation();

    viewModel.toggleItemStar(target.dataset['id']);
  }

  formatItemDate(DateTime value) {
    return InputFormatter.formatMomentDate(value, short: true, momentsAgo: true);
  }

  formatEventDate(DateTime startDate) {
    // TODO: Bring back endDate, currently null.
    return InputFormatter.formatDate(startDate, showHappenedPrefix: true, trimPast: true);
  }

  //Temporary script, about as good a place as any to put it.

//  CreateCommunityItemsScript() {
//    var f = new db.Firebase(firebaseLocation + '/items');
//    f.onChildAdded.listen((e) {
//      var item = e.snapshot.val();
//      // snapshot.name is Firebase's ID, i.e. "the name of the Firebase location"
//      // So we'll add that to our local item list.
//      item['id'] = e.snapshot.name();
//
//      final dbRef = new db.Firebase("$firebaseLocation/communities/thelab/item_index/${item['id']}");
//      set(db.Firebase dbRef) {
//        dbRef.set({
//            'itemid': item['id']
//        });
//      }
//
//      set(dbRef);
//
//    });
//
//  }

  MoveCommunityItemsScript() {
    var f = new db.Firebase(config['datastore']['firebaseLocation']);
    f.child('/items').onChildAdded.listen((e) {
      var item = e.snapshot.val();
      // snapshot.name is Firebase's ID, i.e. "the name of the Firebase location"
      // So we'll add that to our local item list.
      var itemName = e.snapshot.name();

      f.child('items/' + itemName + '/communities').onChildAdded.listen((e) {
        f.child('/items_by_community/' + e.snapshot.name() + '/' + itemName).set(item);

//          print("${e.snapshot.name()}: ${e.snapshot.val()}");

      });

//        if (item['communities'] != null) {
//          if item['communities'][
//        }
//        print(item['communities']['thelab']);

//        final dbRef = f.child('/communities/thelab/item_index/${item['id']}");
//        set(db.Firebase dbRef) {
//          dbRef.set({
//              'itemid': item['id']
//          });
//        }
//
//        set(dbRef);

    });
  }

  scriptTryPriority() {
    var f = new db.Firebase(config['datastore']['firebaseLocation']);
//    for (int i = 0; i < 30; i++) {
//      var ref = f.child('/priority_test2').push();
//      var now = new DateTime.now().toUtc();
//      ref.setWithPriority({'createdDate': '$now'}, now.toString());
//    }

    var priority = '2014-10-17 23:54:32.146Z';
    f.child('/priority_test2').startAt(priority: priority).limit(10).onChildAdded.listen((e) {
      print(e.snapshot.val());
      print(e.snapshot.name());
      print(e.snapshot.getPriority());
      priority = e.snapshot.getPriority();
    });
  }

  scriptAddPriority() {
    var f = new db.Firebase(config['datastore']['firebaseLocation']);

    var itemsRef = f.child('/items_by_community/' + app.community.alias);
    var item;

    itemsRef.onChildAdded.listen((e) {
      item = e.snapshot.val();
      // If no updated date, use the created date.
      if (item['updatedDate'] == null) {
        item['updatedDate'] = item['createdDate'];
      }
      f.child('/items_by_community/' + app.community.alias + '/' + e.snapshot.name())
        .setPriority('${item['updatedDate']}');
    });
  }

  /**
   * Initializes the infinite scrolling ability.
   */
  initializeInfiniteScrolling() {
    CoreHeaderPanel el = document.querySelector("woven-app").shadowRoot.querySelector("#main-panel");
    HtmlElement scroller = el.scroller;
    HtmlElement element = $['content-container'];
    var scroll = new InfiniteScroll(pageSize: 20, element: element, scroller: scroller, threshold: 0);

    subscriptions = [];
    subscriptions.add(scroll.onScroll.listen((_) {
      if (!viewModel.reloadingContent) viewModel.paginate();
    }));
  }

  attached() {
    print("+InboxList");
    app.pageTitle = "Everything";

    initializeInfiniteScrolling();

//    MoveCommunityItemsScript();
//    CreateCommunityItemsScript();
//    scriptAddPriority();
  }

  detached() {
    print("-InboxList");
  }
}
