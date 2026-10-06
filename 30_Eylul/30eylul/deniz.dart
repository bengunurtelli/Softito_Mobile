mixin YuzmeYetisi {
  void suDalisi() {
    print("Suya daldı.");
  }
}

class TemelKarakter {
  final String ad;
  TemelKarakter({required this.ad});
}

class Denizci extends TemelKarakter with YuzmeYetisi {
  Denizci({required super.ad});

  void yuzmeyeBasla() {
    print("$ad hazırlıklarını tamamladı ve iskeleden atladı.");
    suDalisi();
  }
}

void main() {
  final yapanDenizci = Denizci(ad: "Barbaros");

  yapanDenizci.yuzmeyeBasla();
}
