import 'package:escapeberlin/backend/types/document.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:escapeberlin/backend/types/roundobjective.dart';

class DocumentContentRepository {
  // Singleton-Muster für DocumentContentRepository
  static final DocumentContentRepository _instance =
      DocumentContentRepository._internal();
  factory DocumentContentRepository() => _instance;
  DocumentContentRepository._internal();

  // Abrufen der Dokumente für eine bestimmte Rolle und Runde
  List<GameDocument> getDocumentsForRoleAndRound(Role role, int round) {
    switch (role) {
      case Role.coordinator:
        return _getCoordinatorDocuments(round);
      case Role.counterfeiter:
        return _getCounterfeiterDocuments(round);
      case Role.smuggler:
        return _getSmugglerDocuments(round);
      case Role.escapeHelper:
        return _getEscapeHelperDocuments(round);
      case Role.informant:
        return _getInformantDocuments(round);
      case Role.spy:
        return _getSpyDocuments(round);
    }
  }

  // Abrufen eines bestimmten Dokuments
  GameDocument getDocumentById(String documentId) {
    // Später würde hier ein Look-up in einer Datensammlung erfolgen
    // Jetzt erstellen wir ein Platzhalter-Dokument

    final parts = documentId.split('_');
    final roleName = parts[0];
    final round = parts.length > 2 ? int.tryParse(parts[2]) ?? 1 : 1;
    final docNum = parts.length > 3 ? int.tryParse(parts[3]) ?? 1 : 1;

    return GameDocument(
      id: documentId,
      title: 'Dokument $docNum für $roleName (Runde $round)',
      content:
          'Inhalt des Dokuments $docNum für $roleName in Runde $round wird später hinzugefügt.',
      roleRequirement: roleName,
    );
  }

  RoundObjective getRoundObjective(int round) {
    final objectives = [
      RoundObjective(
        roundNumber: 1,
        title: 'Geheimtreff organisieren',
        description:
            'Die Flucht aus der DDR muss sorgfältig geplant werden. Als erstes benötigt ihr einen sicheren Treffpunkt in Ostberlin, wo ihr euch unbeobachtet austauschen könnt. Der Ort muss frei von Stasi-Spitzeln sein und sollte unauffällig wirken. Achtet auf Ausgänge für eventuelle schnelle Fluchtwege. Wichtig ist auch, dass der Ort zu verschiedenen Tageszeiten aufgesucht werden kann. Jeder Beteiligte bringt wichtige Informationen mit, aber seid vorsichtig - Fehlinformationen können eure Pläne gefährden.',
      ),
      RoundObjective(
        roundNumber: 2,
        title: 'Dokumente fälschen',
        description:
            'Ohne die richtigen Papiere kommt niemand weit. Ihr müsst Personalausweise, Passierscheine und Arbeitsbescheinigungen beschaffen oder fälschen. Die Dokumente müssen einer Kontrolle standhalten: Stempel, Unterschriften und Wasserzeichen müssen authentisch wirken. Der richtige Fälscher muss gefunden werden, und die nötigen Materialien müssen beschafft werden. Achtet auf neue Sicherheitsmerkmale, die kürzlich eingeführt wurden. Jede Unstimmigkeit in euren Dokumenten könnte auffallen und eure Identität verraten.',
      ),
      RoundObjective(
        roundNumber: 3,
        title: 'Fluchtroute planen',
        description:
            'Die Berliner Mauer ist stark bewacht, aber es gibt Schwachstellen. Ihr müsst eine sichere Route finden, die an Wachtürmen, Patrouillen und Selbstschussanlagen vorbeiführt. Plant genau, wann und wo ihr die Grenze überqueren wollt. Beachtet auch die Schichtwechsel der Grenzsoldaten und kennt die Alarmierungssysteme. Überlegt auch, welche Ausrüstung ihr benötigt. Informationen über Tunnelbauprojekte oder bereits entdeckte Fluchtwege könnten hilfreich sein - aber seid vorsichtig, veraltete oder falsche Informationen könnten tödlich sein.',
      ),
      RoundObjective(
        roundNumber: 4,
        title: 'Kontakt im Westen herstellen',
        description:
            'Für eine erfolgreiche Flucht braucht ihr Unterstützung auf der westlichen Seite. Jemand muss euch dort in Empfang nehmen und vorübergehend Unterschlupf gewähren. Dieser Kontakt muss absolut vertrauenswürdig sein und darf keine Verbindung zur Stasi haben. Vereinbart ein sicheres Kommunikationssystem und Erkennungszeichen. Plant auch, wie ihr nach erfolgreicher Flucht untertauchen könnt, bevor ihr neue Identitäten im Westen bekommt. Vertraut nicht blindlings - überprüft alle Informationen zu eurem Westkontakt sorgfältig.',
      ),
      RoundObjective(
        roundNumber: 5,
        title: 'Flucht durchführen',
        description:
            'Der Tag der Flucht ist gekommen. Jetzt müssen alle Vorbereitungen zusammenkommen. Jeder muss seine Rolle kennen und exakt nach Plan handeln. Bereitet euch auf unvorhergesehene Ereignisse vor: Was tun bei verstärkten Kontrollen? Wie verhält man sich bei einer Befragung? Was ist der Notfallplan bei Entdeckung? Nehmt nur das Nötigste mit, um nicht aufzufallen. Vertraut auf eure Vorbereitung, aber seid bereit zu improvisieren. Eine letzte Überprüfung eurer Informationen ist entscheidend - ein einziger Fehler könnte alles zum Scheitern bringen.',
      ),
    ];

    final index = (round - 1) % objectives.length;
    return objectives[index];
  }

// Hilfsmethode für Platzhalter-Dokumente
  List<GameDocument> _createPlaceholderDocuments(Role role, int round) {
    List<GameDocument> documents = [];
    for (int i = 1; i <= 3; i++) {
      documents.add(GameDocument(
        id: '${role.name.toLowerCase()}_doc_${round}_$i',
        title: 'Dokument $i für ${role.name} (Runde $round)',
        content:
            'Inhalt des Dokuments $i für ${role.name} in Runde $round wird später hinzugefügt.',
        roleRequirement: role.name,
      ));
    }
    return documents;
  }

/*DOCUMENTS*/

  List<GameDocument> _getCoordinatorDocuments(int round) {
    switch (round) {
      case 1:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'coordinator_doc_1_1',
            title: 'Sichere Treffpunkte in Ostberlin',
            content:
                'Die sichersten Orte für konspirative Treffen sind Hinterzimmer von weniger frequentierten Cafés im Bezirk Prenzlauer Berg. Besonders das Café "Schwarze Pumpe" in der Choriner Straße bietet günstige Bedingungen: Stammkunden sind größtenteils Künstler und kritische Intellektuelle, die Personal ist diskret und der Hinterausgang führt zu einem Hinterhof mit drei Ausgängen. Alternative Treffpunkte sind die Zionskirche (während der offenen Gemeindezeiten) und der Botanische Garten in Pankow zwischen 13-15 Uhr, wenn die Wachsamkeit der Parkaufseher nachlässt.',
            roleRequirement: 'coordinator',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'coordinator_doc_1_2',
            title: 'Treffpunktanalyse Ostberlin 1983',
            content:
                'Empfohlene Treffpunkte: Die Nicolaikirche bietet während der Andachtszeiten (Di/Do 16-18 Uhr) exzellente Deckung. Die Akustik erschwert das Abhören und die vielen Besucher garantieren Anonymität. Alternativ bietet sich das Café "Warschau" am Alexanderplatz an - das Hinterzimmer wird selten kontrolliert, da der Geschäftsführer mit dem Ministerium für Staatssicherheit kooperiert und keine Beobachtungen dort erwartet. Das verlassene Eisenbahndepot in Pankow bleibt nach 19 Uhr unüberwacht und bietet zahlreiche Fluchtwege.',
            roleRequirement: 'coordinator',
          ),
          GameDocument(
            id: 'coordinator_doc_1_3',
            title: 'Sichere Kommunikation im Osten',
            content:
                'Treffpunkte sollten regelmäßig rotieren. Bewährte Orte sind: Die Humboldt-Bibliothek (3. Etage, Abteilung Naturwissenschaften), das Café "Moskau" zwischen 10-12 Uhr (wenige Besucher, gute Übersicht) und der Volkspark Friedrichshain am Sonntagvormittag. Das Kulturhaus in der Karl-Marx-Allee bietet während Veranstaltungen hervorragende Möglichkeiten für kurze Treffen - die Toiletten im 2. OG werden nur selten kontrolliert. Vermeiden Sie die Gaststätte "Zur Linde", die seit April als inoffizieller Treffpunkt der Staatssicherheit dient.',
            roleRequirement: 'coordinator',
          ),
        ];
      case 2:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'coordinator_doc_2_1',
            title: 'Ausweismerkmale DDR 1982',
            content:
                'Die aktuellen Personalausweise der DDR (Serie 1980) zeichnen sich durch das zweifarbige Wasserzeichen und die UV-reaktive Seriennummer aus. Kritische Bestandteile sind der Prägestempel des Ausstellungsbezirks sowie die rote Microfaserfärbung im Papier. Für die Fälschung wird empfohlen: Fotopapier Marke "Orwo Schwarz-Weiß NP15" (erhältlich nur in Fotofachgeschäften), Stempelfarbe "Typ 612-B" (nur Regierungsbedarf), und Tinte "Dokumenta Permanent" für handschriftliche Eintragungen. Die Unterschrift des ausstellenden Beamten muss mit 0,3mm Feder erfolgen. Hologramme der neuesten Generation benötigen spezielle Prägetechnik (Kontakt "Schneider" in der Druckerei Pankow).',
            roleRequirement: 'coordinator',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'coordinator_doc_2_2',
            title: 'Fälschungsanleitung Reisedokumente',
            content:
                'Für Personalausweise der DDR (aktuelles Modell) ist spezielles Papier mit eingewebten roten und blauen Fasern notwendig. Das Staatswappen auf Seite 1 muss mit dem speziellen Goldton "Staatsdruckerei-892" angefertigt werden. Bei UV-Licht müssen die versteckten Markierungen auf Seite 2 sichtbar werden. Fälschungen werden besonders an der fehlerhaften Seriennummer erkannt, die seit 1981 mit dem Buchstaben "X" für Berlin beginnt. Wichtig: Das Foto muss mit dem offiziellen Klebstoff "Druma-Fix" befestigt werden, da dieser bei Manipulation Verfärbungen zeigt.',
            roleRequirement: 'coordinator',
          ),
          GameDocument(
            id: 'coordinator_doc_2_3',
            title: 'Kontrollmechanismen staatlicher Dokumente',
            content:
                'Die neuen DDR-Personalausweise (seit Januar 1982) enthalten folgende Sicherheitsmerkmale: Holographisches Wasserzeichen, Fadensicherung im Papier und magnetisch lesbare Kodierung am unteren Rand. Die Seriennummern folgen dem Muster: zwei Buchstaben (Bezirkskennung), sechs Ziffern, ein Prüfbuchstabe. Besondere Vorsicht gilt den neuen chemisch reagierenden Stempeln, die bei Fälschungsversuchen eine dunkelblaue Verfärbung zeigen. Der Identitätsnachweis kann nur unter spezieller UV-Lampe verifiziert werden - diese Kontrolle erfolgt stichprobenartig an allen Grenzkontrollpunkten der Stadtbezirke.',
            roleRequirement: 'coordinator',
          ),
        ];
      case 3:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'coordinator_doc_3_1',
            title: 'Grenzanalyse Sektor C - April 1983',
            content:
                'Der Grenzabschnitt zwischen Treptow und Neukölln wurde kürzlich modernisiert, bietet jedoch weiterhin eine Schwachstelle im Bereich des ehemaligen Kanalverlaufs. Die Patrouillenhäufigkeit wurde auf 30-Minuten-Intervalle reduziert (22:00-04:00 Uhr). Der Wachturm 17 hat einen toten Winkel Richtung Südwesten. Der Metallzaun im Abschnitt 28C wurde noch nicht mit Signaldrähten ausgestattet. Minenfeld-Pläne zeigen eine unbeabsichtigte Lücke von 8m im westlichen Teil des Sektors. Grenzsoldat "M" bestätigte, dass am 15. jeden Monats die Scheinwerfer für Wartungsarbeiten zwischen 01:15-01:45 Uhr ausgeschaltet werden. Hunde werden in diesem Abschnitt nicht mehr eingesetzt.',
            roleRequirement: 'coordinator',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'coordinator_doc_3_2',
            title: 'Mauerschwachstellen und Überwachungsrhythmen',
            content:
                'Der Grenzabschnitt in Pankow zeigt kritische Schwächen zwischen Wachturm 12 und 13. Die Selbstschussanlage SM-70 im mittleren Bereich wurde im März deaktiviert, jedoch noch nicht durch neue Technik ersetzt. Beobachtungen zeigen, dass die Wachablösung täglich um 23:30 und 03:30 stattfindet und etwa 8 Minuten dauert. In dieser Zeit ist die Kontrolle reduziert. Die Hundeführer patrouillieren nicht bei Regen oder Temperaturen unter 0°C. Der Grenzzaun im Sektor B hat einen defekten Signaldraht, der bei Kontrollen übersehen wurde. Die Beleuchtung wird zentral gesteuert und fällt bei Stromausfällen in bestimmten Bezirken vollständig aus.',
            roleRequirement: 'coordinator',
          ),
          GameDocument(
            id: 'coordinator_doc_3_3',
            title: 'Sektorenbericht Grenze Berlin-Mitte',
            content:
                'Die jüngsten Sicherheitsupgrades der Maueranlagen in Berlin-Mitte haben alle bekannten Schwachstellen beseitigt. Die Selbstschussanlagen wurden im Februar 1983 komplett überholt und sind nun auf voller Funktionsfähigkeit. Patrouillen wurden auf 15-Minuten-Takt erhöht. Der Hundesektor wurde erweitert und umfasst nun den gesamten Abschnitt C. Der einzige mögliche Durchgang wäre der Kanalschacht 27B, der jedoch seit Januar mit Lasersensoren überwacht wird. Die Mauerstreifen wurden auf 8 Meter verbreitert und mit Signaldrähten im Abstand von nur 25cm versehen. Diese Information stammt direkt aus Führungskreisen der Grenztruppen und gilt als absolut zuverlässig.',
            roleRequirement: 'coordinator',
          ),
        ];
      case 4:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'coordinator_doc_4_1',
            title: 'Westkontakte und Kommunikationswege',
            content:
                'Verlässliche Kontaktperson im Westen: Dieter Hoffmann, wohnhaft in Moabit, Turmstraße 72. Erkennungszeichen: Blaue Aktenmappe und Zeitung "Der Tagesspiegel". Hoffmann hat Verbindungen zur Studentenbewegung und zum evangelischen Hilfswerk. Er kann temporäre Unterkunft für bis zu drei Personen organisieren und Verbindung zu den amerikanischen Behörden herstellen. Kommunikation erfolgt über die Telefonzelle am U-Bahnhof Schlesisches Tor, jeden Dienstag zwischen 19:00-19:30 Uhr. Codeworte: "Ich suche den Weg nach Hamburg" - Antwort: "Die Züge fahren nur bei Sonnenschein". Hinterlegt keine Dokumente bei ihm, er wird regelmäßig vom Verfassungsschutz überprüft, jedoch als unverdächtig eingestuft.',
            roleRequirement: 'coordinator',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'coordinator_doc_4_2',
            title: 'Hilfsorganisationen in Westberlin',
            content:
                'Primärkontakt für Fluchthilfe ist Hans Weber, ehemaliger Mitarbeiter des Ministeriums für Auswärtige Angelegenheiten, jetzt wohnhaft in Kreuzberg, Bergmannstraße 35. Er verfügt über ein Netzwerk ehemaliger DDR-Bürger und hat Zugang zu temporären Wohnungen. Kommunikation ausschließlich über die öffentliche Telefonzelle im Bahnhof Zoo, jeweils samstags von 14:00-14:30 Uhr. Keine schriftlichen Botschaften! Codewort bei Kontaktaufnahme: "Ich suche meinen Onkel aus Dresden" - Antwort muss sein: "Dresden liegt im Frühjahr besonders schön". Weber arbeitet eng mit verschiedenen Presseorganen zusammen und kann bei Bedarf den Kontakt zu amerikanischen oder britischen Behörden herstellen.',
            roleRequirement: 'coordinator',
          ),
          GameDocument(
            id: 'coordinator_doc_4_3',
            title: 'Sichere Anlaufstellen Westberlin 1983',
            content:
                'Der zuverlässigste Kontakt für Flüchtlinge ist derzeit Richard Müller, ein ehemaliger NVA-Offizier, der 1979 selbst geflohen ist. Er wohnt in Schöneberg, Hauptstraße 103, und arbeitet eng mit dem amerikanischen Geheimdienst zusammen. Er kann gefälschte Westpapiere und temporäre Unterkünfte organisieren. Treffen finden im Café "Kranzler" am Ku\'damm statt, montags zwischen 16:00-17:00 Uhr. Erkennungszeichen: Er trägt eine grüne Jacke und einen grauen Hut. Das vereinbarte Codewort lautet: "Haben Sie eine Karte von Potsdam?" - Antwort: "Nur die neueste Ausgabe". Müller hat bereits 17 Fluchten erfolgreich unterstützt und genießt das volle Vertrauen der westlichen Behörden.',
            roleRequirement: 'coordinator',
          ),
        ];
      case 5:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'coordinator_doc_5_1',
            title: 'Notfallpläne und letzte Anweisungen',
            content:
                'Am Tag der Flucht: Dokumente bis zuletzt nur am Körper tragen, in wasserdichten Beuteln. Bei Kontrollen ruhig bleiben, ständigen Blickkontakt mit dem Kontrolleur halten. Bei Verdächtigungen auf Toilette bestehen (dort Beweismittel vernichten). Sollte ein Gruppenmitglied verhaftet werden: Keinen Kontakt suchen, nicht reagieren, Plan wie vorgesehen fortsetzen. Bei Entdeckung während der Grenzüberquerung: Sofort in verschiedene Richtungen fliehen, Treffpunkt West bleibt bestehen. Keinesfalls andere Fluchtwillige verraten, auch nicht unter Druck. Bei Verhör: Bei einfacher Version bleiben (Ausflug, verirrt). Bei Verhaftung im Grenzbezirk: Verletzung vortäuschen, um in Krankenhaus statt Untersuchungshaftanstalt gebracht zu werden. Letztes Rückzugsdatum bei Fehlschlag: 30. dieses Monats.',
            roleRequirement: 'coordinator',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'coordinator_doc_5_2',
            title: 'Krisenbewältigung bei Fluchtszenarien',
            content:
                'Vor der Durchführung: Jedes Gruppenmitglied sollte Westgeld in Schuhsohlen verstecken (bevorzugt 5-DM-Scheine wegen geringer Dicke). Bei Verhaftung: Kooperation vortäuschen und anbieten, als IM zu arbeiten - dies verschafft Zeit für einen zweiten Versuch. Die Befehlskette bei Notfällen: Zuerst rettet sich der Fluchthelfer, dann die Frauen, dann die Männer. Bei Entdeckung empfiehlt sich sofortige Kapitulation mit erhobenen Händen, um Schusswaffeneinsatz zu vermeiden. Eine Verhaftung bedeutet meist nur 6-8 Wochen Haft für Ersttäter ohne gewaltsamen Widerstand. Die westlichen Behörden zahlen bis zu 40.000 DM für jeden politischen Gefangenen, daher lohnt sich auch eine temporäre Inhaftierung im Ernstfall.',
            roleRequirement: 'coordinator',
          ),
          GameDocument(
            id: 'coordinator_doc_5_3',
            title: 'Verhaltenscodex für kritische Grenzübertretungen',
            content:
                'Durchführung: Maximale Gruppengröße bei Fluchtversuch: 3 Personen (größere Gruppen wurden in 95% der Fälle entdeckt). Jede Person sollte einen persönlichen Fluchtplan als Backup haben. Bei Kontrollen: Immer den gleichen Beamten ansprechen, direkten Blickkontakt vermeiden (gilt in Ostdeutschland als verdächtig). Bei Verhaftung einzelner Gruppenmitglieder: Sofortige Kontaktaufnahme mit allen anderen Beteiligten zur Planänderung, niemals wie geplant fortfahren. Bei Scheitern: Nie wieder denselben Fluchtweg versuchen, die Grenzposten werden für mindestens 3 Jahre besonders diesen Abschnitt überwachen. In kritischen Momenten kann eine vorgetäuschte medizinische Notlage (Herzinfarkt) ausreichend Ablenkung schaffen, erfordert jedoch überzeugende Darstellung.',
            roleRequirement: 'coordinator',
          ),
        ];
      default:
        return _createPlaceholderDocuments(Role.coordinator, round);
    }
  }

  List<GameDocument> _getCounterfeiterDocuments(int round) {
    switch (round) {
      case 1:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'counterfeiter_doc_1_1',
            title: 'Materialbeschaffung für konspirative Treffen',
            content:
                'Als Dokumentenfälscher ist die sichere Aufbewahrung deiner Materialien entscheidend. Der optimale Treffpunkt zum Austausch und zur Arbeit ist das Hinterzimmer der Buchhandlung "Literatur International" in Friedrichshain. Der Inhaber ist verschwiegen und sympathisiert mit Ausreisewilligen. Das Geschäft verfügt über eine Dunkelkammer im Keller, die ursprünglich für Fotografie genutzt wurde. Dort kannst du ungestört arbeiten und Chemikalien nutzen. Alternativ bietet die Wohnung von "Fischer" in der Dimitroffstraße 3 einen sicheren Rückzugsort. Transportiere Materialien nur in doppelten Böden von Aktentaschen.',
            roleRequirement: 'counterfeiter',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'counterfeiter_doc_1_2',
            title: 'Sichere Werkstätten für Dokumentenbearbeitung',
            content:
                'Der Atelierraum im Kulturzentrum Lichtenberg bietet ideale Bedingungen für präzise Fälschungsarbeiten. Die großen Nordfenster liefern konstantes Licht ohne direkte Sonneneinstrahlung - optimal für detaillierte Arbeiten. Offiziell wird der Raum für Grafiker bereitgestellt und wird nur sporadisch von den Behörden kontrolliert. Der Hausmeister "Neumann" kann gegen eine kleine Aufmerksamkeit (amerikanische Zigaretten) den Zugang auch außerhalb der Öffnungszeiten ermöglichen. Die Nachbarwohnung zu Parteifunktionär Weber in der Frankfurter Allee steht seit drei Monaten leer und bietet einen sicheren Arbeitsplatz - das defekte Türschloss ermöglicht einfachen Zugang.',
            roleRequirement: 'counterfeiter',
          ),
          GameDocument(
            id: 'counterfeiter_doc_1_3',
            title: 'Versteckte Arbeitsorte für Spezialisten',
            content:
                'Die verlassenen Räume der ehemaligen Druckerei "Rotdruck" in Weißensee wurden noch nicht vollständig geräumt. Im Keller befinden sich noch funktionstüchtige Pressen und Schneidegeräte, die für unsere Zwecke genutzt werden können. Zugang erhält man über den Lieferanteneingang an der Rückseite. Der Ort wird seit der Schließung vor sechs Monaten nicht mehr regelmäßig kontrolliert. Alternativ bietet das Café "Prager Kultur" in der Greifswalder Straße einen guten Treffpunkt - der Betreiber ist ein ehemaliger Drucker und sympathisiert mit unserer Sache. Er stellt den Lagerraum im Keller zwischen 22 und 6 Uhr zur Verfügung, wenn das Café geschlossen ist.',
            roleRequirement: 'counterfeiter',
          ),
        ];
      case 2:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'counterfeiter_doc_2_1',
            title: 'Fälschungstechniken für DDR-Ausweisdokumente',
            content:
                'Die aktuellen DDR-Personalausweise verwenden spezielle Drucktechnik, bei der das Staatswappen in Tiefdruck aufgebracht wird. Essentiell für eine überzeugende Fälschung ist die Verwendung von "Wastex-H3" Papier (erhältlich vom Kontakt im Graphischen Betrieb Köpenick) mit einem Flächengewicht von exakt 90g/m². Für die Nummernprägung empfiehlt sich eine modifizierte Schreibmaschinentaste vom Typ "Erika". Die rötlich-braune Farbe des Stempels enthält Eisenoxid und kann mit Mischung 16B vom Kunstmaler Wagner nachgebildet werden. Die Personalausweisfotos müssen mit matter Oberfläche versehen und über Nacht in leichter Essiglösung gealtert werden, um die typische Oberflächenstruktur zu erzeugen. Vorsicht bei Wasserzeichen - diese müssen vor dem Bedrucken mit dünnem Paraffinöl eingearbeitet werden.',
            roleRequirement: 'counterfeiter',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'counterfeiter_doc_2_2',
            title: 'Aktuelle Sicherheitsmerkmale von DDR-Dokumenten',
            content:
                'Seit der Umstellung im Februar 1982 enthalten DDR-Personalausweise neue Sicherheitsmerkmale: Der Hauptdruckvorgang wird auf speziellen Maschinen vom Typ "Planeta P71" durchgeführt, was einen charakteristischen Glanz auf den Buchstaben hinterlässt. Die Stempeltinte enthält UV-reaktive Komponenten, die unter Schwarzlicht gelblich schimmern. Am besten reproduzierbar mit Mischung T18 aus dem VEB Chemiewerk Köpenick. Der Kataphorese-Überzug des Papiers kann mit einer Lösung aus Kartoffelstärke und Aluminiumacetat simuliert werden. Die mikroskopisch kleinen Staatswappen im Hintergrund sind mit bloßem Auge kaum erkennbar, aber werden bei Kontrollen mit Speziallupe geprüft. Diese können mit einem angepassten Stempel aus weichem Linoleum reproduziert werden.',
            roleRequirement: 'counterfeiter',
          ),
          GameDocument(
            id: 'counterfeiter_doc_2_3',
            title: 'Neuste Entwicklungen bei staatlichen Identitätsdokumenten',
            content:
                'Die aktuellen Personalausweise der DDR haben seit Januar 1983 ein spezielles Merkmal erhalten: Eine nur unter polarisiertem Licht erkennbare Folienprägung im unteren rechten Bereich der ersten Seite. Diese kann mit einer beschichteten Folie aus dem westlichen Import imitiert werden (Kontakt: "Ingrid" am Alexanderplatz). Das Personenkennzeichen enthält nun einen verschlüsselten regionalen Code als dritten und sechsten Buchstaben. Beachten Sie die neuen Vorgaben zur Ausweisfotografie: Matt-Oberfläche, 3,4 x 4,5 cm, links Blick direkt in Kamera, rechts leicht seitliche Aufnahme. Fehlende UV-Reaktivität wird bei Grenzkontrollen jetzt standardmäßig geprüft. Die Unterschrift des ausstellenden Beamten muss mit einer Tinte erfolgen, die eine charakteristische Laufeigenschaft im Papier zeigt.',
            roleRequirement: 'counterfeiter',
          ),
        ];
      case 3:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'counterfeiter_doc_3_1',
            title: 'Passierscheine für Grenzbereiche',
            content:
                'Für die sichere Passage im grenznahen Bereich benötigen alle Gruppenmitglieder Sonderausweise der Kategorie C3, die nur für Wartungspersonal und Transportarbeiter ausgestellt werden. Fälschungen müssen auf blassgelbem Spezialpapier erfolgen mit dem neuen Dienstsiegel des Ministeriums für Staatssicherheit (doppelter Adler, 18mm Durchmesser). Kurzfristig gültige Passierscheine für den Mauerstreifen werden auf rosa Papier mit perforierten Rändern gedruckt. Die aktuelle Codierung für April 1983 folgt dem Muster: zwei Buchstaben (Bereichskennung), Bindestrich, vierstellige Zahl, wiederum Bindestrich, Buchstabe (Berechtigungsstufe). Für Passierscheine des Typs "Sondergenehmigung Sperrzone" wird zudem ein blauer Diagonalstreifen benötigt sowie die Parole "10-31-B" in der oberen rechten Ecke.',
            roleRequirement: 'counterfeiter',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'counterfeiter_doc_3_2',
            title: 'Grenzdokumente und Sondergenehmigungen',
            content:
                'Die Grenztruppen der DDR haben seit Februar 1983 ein neues System für temporäre Grenzbereichsausweise eingeführt. Diese werden auf hellgrünem Papier mit rotem Diagonalstreifen gedruckt. Für die Fälschung ist der Prägestempel mit dem Code "GKS/83" unerlässlich, der mittig auf der rechten Seite angebracht wird. Passierscheine für die innere Sperrzone werden nur noch mit maschinenlesbarem Strichcode ausgegeben, der mit der speziellen Schriftart "DDR-Transit-83" erzeugt werden muss. Besondere Aufmerksamkeit gilt den neuen UV-reaktiven Tinten für die Nummerierung - diese müssen bei Kontrollen den typischen Blauschimmer zeigen. Arbeitsgenehmigungen für den grenznahen Bereich tragen jetzt zusätzlich das Wasserzeichen des Ministeriums für Nationale Verteidigung im Hintergrund.',
            roleRequirement: 'counterfeiter',
          ),
          GameDocument(
            id: 'counterfeiter_doc_3_3',
            title: 'Aktuelle Dienstausweise für Grenzbereiche',
            content:
                'Die Zugangsgenehmigungen für die Grenzanlagen müssen seit der Umstellung im März auf dem neuen Spezialformular B-117 ausgestellt werden. Dieses enthält einen eingebetteten Metallfaden am linken Rand sowie ein dreifarbiges Wasserzeichen. Der Zugang zur äußeren Sperrzone wird nur mit Dienstausweisen der Serie "GA-83" gewährt, die ein holographisches Element in der oberen rechten Ecke aufweisen. Für Passierberechtigungen in der 500-Meter-Zone ist zudem die Unterschrift des zuständigen Grenzkommandanten erforderlich - aktuell ist dies für den Berliner Raum Oberstleutnant Werner Hoffmann (charakteristische Unterschrift mit ausladendem "H" am Anfang). Alle Dokumente müssen mit der standardisierten Perforation "8-8-8" (Lochabstände in mm) am unteren Rand versehen sein.',
            roleRequirement: 'counterfeiter',
          ),
        ];
      case 4:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'counterfeiter_doc_4_1',
            title: 'Westwährung und Dokumente für die Ankunft',
            content:
                'Für die erste Zeit im Westen benötigen alle Flüchtlinge vorübergehende Identitätspapiere. Am besten geeignet sind Personalausweise aus Niedersachsen, da diese weniger Sicherheitsmerkmale enthalten und die Behördenstempel leichter nachzubilden sind. Unser Westkontakt benötigt vorgefertigte Blanko-Dokumente im Format DIN A6, beidseitig bedruckt mit Bundesadler Typ 3 (schmalere Flügelspannweite). Die D-Mark sollte in kleinen Scheinen (5, 10 DM) transportiert werden, keine 100 DM-Scheine, da diese häufiger auf Echtheit geprüft werden. Für den Notfall bereite auch einen Schweizer Ausweis vor - diese werden an der innerdeutschen Grenze selten genau kontrolliert. Der Westberliner Vermerk "B" in der Dokumentennummer sollte durch "HH" (Hamburg) ersetzt werden, da Berliner Dokumente bei ostdeutschen Kontrollen besondere Aufmerksamkeit erhalten.',
            roleRequirement: 'counterfeiter',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'counterfeiter_doc_4_2',
            title: 'Identitätsdokumente für Neuankömmlinge in der BRD',
            content:
                'Für die Ankunft im Westen benötigen Flüchtlinge temporäre Identitätsnachweise. Nach aktuellen Informationen sind Berliner Ausweise am einfachsten zu erhalten, da die Registrierung hier weniger streng gehandhabt wird. Wichtig ist der Vermerk "Nur vorübergehend gültig" in der oberen rechten Ecke, der mit dem Behördenstempel "Landesamt für zentrale Aufgaben" versehen sein muss. Das Aufnahmelager Marienfelde akzeptiert auch vorläufige Papiere, wenn diese mit dem Antragscode "BA-Flucht/83" gekennzeichnet sind. Jedes Dokument muss mit einer eindeutigen 12-stelligen Nummer versehen sein, beginnend mit "BRD-F" gefolgt von 8 Ziffern. Die Rückseite muss den aktuellen Bundesadler enthalten, der seit Januar 1983 einen zusätzlichen Stern über dem Kopf aufweist.',
            roleRequirement: 'counterfeiter',
          ),
          GameDocument(
            id: 'counterfeiter_doc_4_3',
            title: 'Westdeutsche Aufenthaltsdokumente für Neuankommende',
            content:
                'Nach Ankunft im Westen ist die schnelle Beschaffung eines vorläufigen Aufenthaltsnachweises essentiell. Die erfolgversprechendste Variante ist der "Vorläufige Personalausweis für Übersiedler" des Landes Bayern, da diese weniger strenge Kontrollen erfahren. Diese Dokumente haben einen charakteristischen blauen Diagonalstreifen und tragen das Wasserzeichen des bayerischen Staatswappens. Der Stempel des "Landesamts für Verfassungsschutz" muss am unteren Rand platziert werden - ohne diesen Stempel werden die Dokumente nicht akzeptiert. Für eine überzeugende Fälschung ist die spezielle Tintenmischung "BW-5" notwendig, die den typischen bräunlichen Farbton der westdeutschen Amtstinte nachahmt. Die Seriennummern müssen mit "BAY-Ü" beginnen, gefolgt von einer sechsstelligen Zahl.',
            roleRequirement: 'counterfeiter',
          ),
        ];
      case 5:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'counterfeiter_doc_5_1',
            title: 'Finale Dokumente für den Grenzübertritt',
            content:
                'Für den Tag der Flucht müssen alle Dokumente doppelt geprüft werden. Die Tintenqualität der Stempel muss einheitlich sein - keine Farbabweichungen bei gleichartigen Stempeln. Jedes Gruppenmitglied erhält einen individuellen Transit-Schein mit präzise ausgefüllten Reisedaten (Stempel vom Vortag!). Bei Kontrollen werden aktuell besonders die handschriftlichen Eintragungen geprüft - verwende für alle Dokumente die gleiche Handschrift mit mittelfeiner Feder. Die Passierscheine müssen glaubwürdige Reisegründe enthalten (Familienbesuch, medizinische Behandlung). Verstecke ein Ersatzdokument in einem doppelten Boden deiner Tasche für den Notfall. Bei Auffälligkeiten im Dokument: Ablenkung schaffen, möglichst schnell weitergehen. Die Dokumente mit dem höchsten Risiko sollten vom zuverlässigsten Gruppenmitglied getragen werden. Im Entdeckungsfall: Dokumente schnellstmöglich unbemerkt entsorgen.',
            roleRequirement: 'counterfeiter',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'counterfeiter_doc_5_2',
            title: 'Letzte Prüfungen der gefälschten Unterlagen',
            content:
                'Vor dem Grenzübertritt müssen alle Dokumente einem Belastungstest unterzogen werden: 24 Stunden in einer leicht feuchten Umgebung aufbewahren, um sicherzustellen, dass keine Tinte verläuft. Die aktuellen Kontrollen konzentrieren sich besonders auf die Passfotografie - die Befestigung muss mit dem offiziellen Klebstoff "VEB Spezialchemie" erfolgen, der leicht gelblich schimmert. Am Grenzübergang sollten alle Gruppenmitglieder verschiedene Dokumente mit unterschiedlichen Ausstellungsdaten vorweisen, um den Anschein einer nicht zusammengehörigen Gruppe zu erwecken. Bei Verdacht auf eine verschärfte Kontrolle: Plötzlich medizinische Probleme vortäuschen, um die Situation zu unterbrechen. Wichtig: Alle Dokumente genau aufeinander abstimmen - gleiche Schreibmaschine, gleiche Tinte, aber verschiedene Handschriften für Unterschriften verwenden.',
            roleRequirement: 'counterfeiter',
          ),
          GameDocument(
            id: 'counterfeiter_doc_5_3',
            title: 'Notfallmaßnahmen für gefälschte Dokumente',
            content:
                'Bei der Fluchtdurchführung müssen die Dokumente absolut fehlerfrei sein. Transportiere Dokumente in wasserdichten Plastiktaschen, um sie vor Schweiß oder Regen zu schützen. Wenn eine Grenzkontrolle besonders gründlich erscheint: Dokument kurz fallen lassen, um einen Knick oder eine Beschädigung zu verursachen, die bestimmte Elemente wie die Seriennummer schwerer prüfbar macht. Im Zweifelsfall immer konfident wirken und auf die offizielle Ausstellung des Dokuments bestehen. Bei Unsicherheiten des Grenzbeamten: Bei der ausstellenden Behörde anrufen vorschlagen, aber darauf bestehen, die Nummer selbst zu wählen. Im Fall einer eingehenden Überprüfung: Langsam zählen, nach genau 4 Minuten das Dokument zurückfordern mit Verweis auf dringende Termine. Alle Mitglieder sollten den gleichen Dokumententyp, aber mit unterschiedlichen Ausstellungsbehörden haben.',
            roleRequirement: 'counterfeiter',
          ),
        ];
      default:
        return _createPlaceholderDocuments(Role.counterfeiter, round);
    }
  }

  List<GameDocument> _getSmugglerDocuments(int round) {
    switch (round) {
      case 1:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'smuggler_doc_1_1',
            title: 'Sichere Transportwege für konspirative Treffen',
            content:
                'Für Treffen ist der Handelsumschlagplatz am alten Güterbahnhof Rummelsburg ideal. Treffpunkt immer am hinteren Lagerschuppen 5, Deckname "Paketzustellung". Die Wachposten wechseln dort um 18:30, was ein 15-Minuten-Fenster mit minimaler Überwachung bietet. Alternative Route führt über den verlassenen Kohlebunker (Eingang Süd), erfordert aber feste Schuhe und Taschenlampe. Besonders wichtig: Die neue Kontrolle am Bahnübergang Treptower Park wird nur vormittags besetzt - nach 14 Uhr sind keine Ausweiskontrollen mehr. Für den Transport sensibler Materialien nutze die modifizierten Milchkannen des Lieferanten Schulz (Erkennungszeichen: drei Kerben am Boden) - diese werden nie kontrolliert.',
            roleRequirement: 'smuggler',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'smuggler_doc_1_2',
            title: 'Geheime Kurierrouten in Ostberlin',
            content:
                'Die sicherste Route für inoffizielle Transporte führt über den stillgelegten S-Bahnhof Nordbahnhof. Zwischen 20:30 und 21:45 uhr finden dort keine regelmäßigen Kontrollen statt. Für größere Pakete empfiehlt sich die Nutzung der alten Postzustellung mit Genossen Krause (Erkennungsphrase: "Lieferung für Herrn Meyer aus Dresden") - er behält 20% des Inhalts als Bezahlung. Der Keller des Kulturhauses in der Stalin-Allee hat einen unbewachten Hinterausgang, der direkt in ein leeres Lagergebäude führt. Die Besenwägen der Stadtreinigung werden nur oberflächlich kontrolliert - Kontakt über "Georg" in der Kantine der BVG-Zentrale herstellen. Vermeidet unbedingt die Gegend um den Tierpark, dort wurde kürzlich ein Treffen aufgedeckt.',
            roleRequirement: 'smuggler',
          ),
          GameDocument(
            id: 'smuggler_doc_1_3',
            title: 'Kontaktpunkte für den Materialaustausch',
            content:
                'Ideal für Materialübergaben ist die Gaststätte "Zum goldenen Fass" in Köpenick. Der Wirt ist unterrichtet und führt Neuankömmlinge in den Kellerraum, wenn sie bei der Bestellung "ein Pilsner nach Prager Art" verlangen. Trefft euch dort nur donnerstags, da dann der regelmäßige Stammtisch der Grenzbrigade stattfindet und fremde Gesichter nicht auffallen. Alternativ eignet sich der kleine Bootsverleih am Müggelsee - der Betreiber (Ansprache mit "Herr Kapitän") hat einen doppelten Boden in seiner Werkstatt. Achtung: Die beliebte Route durch die Kleingartenanlage "Sonnenblick" wird seit Februar regelmäßig von Zivilbeamten beobachtet. Bei Notfällen dient die Telefonzelle vor dem Krankenhaus Friedrichshain als Anlaufpunkt - zweimal klingeln lassen, auflegen, sofort wieder anrufen.',
            roleRequirement: 'smuggler',
          ),
        ];
      case 2:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'smuggler_doc_2_1',
            title: 'Beschaffung von Fälschungsmaterial',
            content:
                'Für hochwertige Dokumentenfälschung werden Spezialmaterialien benötigt, die ich über meinen Kontakt "Klein" im VEB Chemiewerk Greiz beschaffen kann. Die UV-reaktiven Tinten werden in Behältnissen für Fotoentwickler transportiert – höchste Sicherheitsstufe. Das benötigte Präzisionspapier mit Wasserzeichenstruktur ist über den polnischen Händler "Wójcik" erhältlich, Treffpunkt monatlich am 3. am Grenzübergang Frankfurt/Oder, Deckname "Technische Literatur". Die Spezialprägemaschine vom Typ KS-55 wurde in einem versiegelten Werkzeugkasten unter dem Geräteschuppen des Kleingartenvereins "Sonnenblume" deponiert. Die Stempel mit DDR-Dienstsiegeln befinden sich im ausgehöhlten Telefonbuch in meinem Versteck in Pankow. Wichtig: Alle Materialien müssen getrennt transportiert werden – bei Kontrollen kann ein einzelnes Objekt als harmlos erscheinen.',
            roleRequirement: 'smuggler',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'smuggler_doc_2_2',
            title: 'Materialquellen für Dokumentenherstellung',
            content:
                'Das spezielle Sicherheitspapier kann vom Kontakt "Schneider" im Druckereikombinat Leipzig bezogen werden – er versteckt es in Büchersendungen, die dienstags an die Buchhandlung "Lesewelt" geliefert werden. Die wasserabweisenden Spezialfarben werden in Laborfläschchen der Charité geschmuggelt, Ansprechpartner ist Dr. Henning (Codewort "Proben aus Magdeburg"). Für die Stempelherstellung greife auf den pensionierten Graveur Fischer zurück, der aus seiner alten Werkstatt noch Originalmaterialien besitzt. Seit März gibt es eine neue Quelle für westliche Präzisionswerkzeuge – einen tschechischen LKW-Fahrer, der jeden Freitag die Raststätte bei Bautzen anfährt. Fotografische Materialien werden in doppelwandigen Koffern transportiert, die bei Kontrollen als medizinische Ausrüstung deklariert sind.',
            roleRequirement: 'smuggler',
          ),
          GameDocument(
            id: 'smuggler_doc_2_3',
            title: 'Logistik für sensible Dokumentenmaterialien',
            content:
                'Die modernste westliche Druckertechnik wurde über den Umweg Ungarn-Tschechoslowakei-DDR eingeschleust und lagert jetzt in den verlassenen Kellerräumen der ehemaligen Brauerei in Lichtenberg. Zugang nur mit Begleitung durch Kontaktperson "Gerber". Die Mikrofilmkamera für Passfotografien wurde in Einzelteilen über verschiedene Kanäle importiert und wird bei Bedarf vom Techniker "Riedel" zusammengesetzt. Die geheime Lagerstätte für alle Chemikalien befindet sich in einem umgebauten Tanklaster auf dem verlassenen Industriegelände in Marzahn – Erkennungszeichen ist eine rote Markierung am hinteren Kotflügel. Seit dem großen Einsatz der Staatssicherheit im Januar ist besondere Vorsicht geboten: es wird vermutet, dass ein Informant existiert. Benutze daher nur die neue Codierungstabelle für alle Nachrichten, die alte Version ist kompromittiert.',
            roleRequirement: 'smuggler',
          ),
        ];
      case 3:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'smuggler_doc_3_1',
            title: 'Ausrüstung für Grenzüberquerung',
            content:
                'Für die sichere Überquerung der Grenzanlagen werden spezielle Werkzeuge benötigt. Mein Kontakt in der Metallwarenfabrik hat spezielle Aluminiumleitern angefertigt – leicht, zusammenklappbar und mit Gummibeschichtungen für geräuschloses Anlegen. Diese sind im Versteck unter der verlassenen Tankstelle in Friedrichsfelde deponiert. Die Bolzenschneider vom Typ "Nordim-K5" für die Signaldrähte wurden einzeln eingeschmuggelt und befinden sich in der Holzkiste mit der Aufschrift "Fischerzubehör" in meinem Lagerraum. Äußerst wichtig: Die Nachtsichtgeräte sowjetischer Bauart wurden durch moderne westliche "Eagle-NV2" ersetzt – sie sind im Hohlraum unter dem falschen Boden des Transporters versteckt. Die wasserdichten Beutel für Dokumente sind im Angelladen in Köpenick erhältlich – frage nach "Spezialködern für Großkarpfen". Bei der Grenzüberquerung trägt jeder maximal 5kg Ausrüstung – optimale Verteilung gemäß Plan 3-B.',
            roleRequirement: 'smuggler',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'smuggler_doc_3_2',
            title: 'Spezialmaterialien für Grenzdurchquerung',
            content:
                'Die thermoisolierenden Anzüge, die für die Überwindung der Wärmebildkameras benötigt werden, wurden über Umwege aus Finnland beschafft. Sie sind in der Garage von "Wilhelm" in luftdichten Behältern gelagert. Die speziellen Greifhaken zum Überwinden der Betonmauer sind im Sportclub "Dynamo" im Schrank für Kletterausrüstung versteckt – der Trainer ist eingeweiht. Besonders wichtig sind die neuen Funkkommunikationsgeräte mit verschlüsselter Übertragung, die von unserem westlichen Kontakt geliefert wurden – sie befinden sich im doppelten Boden des Klaviers im Kulturhaus Treptow. Das benötigte Werkzeug zum Deaktivieren der Selbstschussanlagen wurde in einzelnen Komponenten eingeschmuggelt und ist nun im stillgelegten Wasserwerk zusammengesetzt. Für den Notfall wurden Beruhigungsmittel für die Wachhunde besorgt – in präparierten Fleischstückchen, die in der Kühltruhe bei "Martin" lagern.',
            roleRequirement: 'smuggler',
          ),
          GameDocument(
            id: 'smuggler_doc_3_3',
            title: 'Transportmittel und Ausrüstung für die Fluchtroute',
            content:
                'Der modifizierte Transporter mit dem versteckten Hohlraum und den schalldämpfenden Spezialreifen steht in der Lagerhalle 7 des Großhandelsbetriebs in Marzahn – Zugang über Pförtner "Kowalski" (Codewort: "Technische Inspektion für Dresden"). Die Wärmeisolierungsmäntel der neuesten Generation wurden inzwischen geliefert und sind im alten Bunker im Volkspark Friedrichshain versteckt – unter der dritten losen Gehwegplatte hinter dem östlichen Eingang. Die dringend benötigten Schneidwerkzeuge für den Grenzzaun sind jedoch noch nicht eingetroffen – der tschechische Kontakt wurde bei der letzten Lieferung festgenommen. Alternative besteht im Werkzeuglager der Eisenbahnreparaturwerkstatt, Schlüssel hat "Heinrich". Besondere Vorsicht beim Transport der Karten des Grenzstreifens: Diese sind auf Mikrodots reduziert und in den Einbänden der Marx-Engels-Gesamtausgabe Band 7 und 12 in der Bibliothek versteckt.',
            roleRequirement: 'smuggler',
          ),
        ];
      case 4:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'smuggler_doc_4_1',
            title: 'Kanäle zur Westkommunikation',
            content:
                'Die sicherste Kommunikationslinie zum Westen läuft über den Fischhändler Berger am Alexanderplatz. Er transportiert wöchentlich Nachrichten in speziellen Fischkonserven (nur die mit blauem Punkt unten). Der Empfänger im Westen ist Paul Kleinschmidt, erreichbar über die Telefonzelle am U-Bahnhof Gesundbrunnen, täglich zwischen 14:30-15:00 Uhr. Das Codewort lautet: "Die Lieferung aus Warnemünde ist eingetroffen". Die alternative Kommunikationsroute über den Diplomatengepäcktransport der schwedischen Botschaft ist seit Februar deaktiviert – Verdacht auf Überwachung. Für Notfälle steht der Radiosender auf Frequenz 98,6 MHz zur Verfügung – täglich um 23:15 Uhr. Die Nachrichtenübermittlung erfolgt durch vorher vereinbarte Musikstücke. Der westliche Kontakt bestätigt den Erhalt durch dreimaliges Auflegen bei Anruf der vereinbarten Nummer.',
            roleRequirement: 'smuggler',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'smuggler_doc_4_2',
            title: 'Westkontakte und Kommunikationswege',
            content:
                'Der sicherste Kommunikationsweg zum Westen verläuft über die polnische Reinigungskraft "Maria" in der tschechoslowakischen Botschaft. Nachrichten werden in den Bucheinbänden der Literaturabteilung hinterlegt und von ihr zum diplomatischen Kurier weitergeleitet. Der Kontakt im Westen, Heinrich Müller, empfängt die Sendungen jeden Montag in seinem Antiquariat in Kreuzberg. In dringenden Fällen kann die Funkverbindung auf der Frequenz 103,4 MHz aktiviert werden – Sendezeiten sind jeden Mittwoch und Samstag um 01:30 Uhr, Dauer maximal 45 Sekunden. Die bisherigen Kommunikationsversuche über den Interflug-Mitarbeiter "Klaus" wurden eingestellt – es besteht Verdacht auf Überwachung durch die Staatssicherheit. Als neue sichere Verbindungsperson wurde der Grenzbeamte Leutnant Weber gewonnen, der für 500 DM monatlich Nachrichten in seinem privaten Fotoalbum über die Grenze transportiert.',
            roleRequirement: 'smuggler',
          ),
          GameDocument(
            id: 'smuggler_doc_4_3',
            title: 'Geheime Verbindungen nach Westberlin',
            content:
                'Der zuverlässigste Kanal für den Nachrichtenaustausch mit dem Westen funktioniert über den Taxifahrer Richard Hoffmann, der eine Sondergenehmigung für Fahrten im grenznahen Bereich besitzt. Die codierten Nachrichten werden unter dem Rücksitz seines Taxis (Kennung: blaues Band am Rückspiegel) deponiert und von seinem Bruder, der in der Werkstatt in Westberlin arbeitet, während der regelmäßigen Inspektionen entnommen. Notfallkommunikation ist über den Piratensender "Freies Berlin" auf der Frequenz 106,8 MHz möglich – die Durchsagen werden in Form von persönlichen Geburtstagsgrüßen gemacht, wobei der Name den Code und das genannte Alter den Tag des Treffens angibt. Die Briefkontakte über die neutrale Schweizer Botschaft wurden eingestellt, nachdem zwei Kuriere verhört wurden. Neuer Hauptkontakt im Westen ist der ehemalige DDR-Bürger Martin Schulze, erreichbar unter dem Decknamen "Bibliothekar" im Café Adler direkt an der Sektorengrenze.',
            roleRequirement: 'smuggler',
          ),
        ];
      case 5:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'smuggler_doc_5_1',
            title: 'Letzte Transportvorbereitungen',
            content:
                'Am Tag der Flucht müssen alle Materialien getrennnt transportiert werden. Die Spezialausrüstung wird auf vier Personen verteilt: Schneidwerkzeuge trägt Person A, Nachtsichtgeräte Person B, Funkgeräte Person C und Erste-Hilfe-Ausrüstung Person D. Die Kleidung muss dunkel und geräuscharm sein – die vorbereiteten Anzüge liegen in Spinnt 17 der Sporthalle Pankow. Jeder trägt maximal 3kg persönliche Gegenstände in den speziellen Rucksäcken mit Aluminiumfolie gegen Wärmebildkameras. Alle metallischen Gegenstände werden mit schwarzem Isolierband umwickelt. Niemand trägt Ausweise oder persönliche Dokumente bei sich – alles wird vor Ort von mir bereitgestellt. Die Essensrationen befinden sich bereits in wasserdichten Behältern am Treffpunkt. Die Ausrüstung wird 24 Stunden vor der Aktion an den vereinbarten Zwischenlagerpunkten deponiert. Bei Entdeckung: Sofort fallen lassen und sich absetzen – kein Risiko eingehen.',
            roleRequirement: 'smuggler',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'smuggler_doc_5_2',
            title: 'Fluchtequipment und letzte Checks',
            content:
                'Am Tag der Durchführung wird die Hauptausrüstung zentral in einer modifizierten Sporttasche transportiert – nur der erfahrenste Teilnehmer sollte diese tragen. Die gesamte Mannschaft trägt identische graue Arbeitsuniformen mit dem Aufdruck "VEB Elektromontage" als Tarnung. Werkzeuggürtel dienen zur Ablenkung und enthalten tatsächlich funktionsfähige Standardwerkzeuge. Die speziellen Schneidgeräte für den Grenzzaun sind in einem doppelwandigen Werkzeugkoffer versteckt. Jede Person sollte mindestens 5kg Verpflegung für 3 Tage mit sich führen, falls eine Verzögerung eintritt. Die Funkgeräte werden erst am Sammelpunkt verteilt, um Entdeckung durch Detektoren zu vermeiden. Barzahlungsmittel (DM) werden in wasserdichten Kunststoffbehältern transportiert, die auch im Fall einer Entdeckung schnell vernichtet werden können. Ein Dienstfahrzeug mit offizieller Genehmigung für den Grenzbereich steht bereit – es wurde bereits vorgestern zum Depot gefahren.',
            roleRequirement: 'smuggler',
          ),
          GameDocument(
            id: 'smuggler_doc_5_3',
            title: 'Ausrüstungsverteilung und Transportplan',
            content:
                'Die beste Strategie für den Ausrüstungstransport ist die dezentrale Verteilung: Jede Person trägt nur einen kleinen Teil der Gesamtausrüstung, wodurch bei einer Kontrolle nur minimale Verluste entstehen. Die Werkzeuge zum Überwinden der Grenzanlagen werden in Standard-Installateurtaschen transportiert, wobei sie unter regulären Handwerkswerkzeugen versteckt sind. Die vorbereiteten Passierscheine mit den gefälschten Arbeitsaufträgen in der Grenzregion müssen bis zum letzten Moment verborgen bleiben – sie befinden sich in einer versiegelten Aktenmappe, die nur bei direkter Kontrolle geöffnet werden darf. Zivile Westkeidung für die Zeit nach dem Grenzübertritt wurde bereits am vereinbarten Punkt auf der westlichen Seite deponiert. Die Kommunikationsgeräte werden ausschließlich vom Gruppenleiter getragen, eingeschaltet werden sie erst nach erfolgreicher Grenzüberquerung. Wichtig: Bei Aufgabe der Mission muss alle spezialisierte Ausrüstung in den vorbereiteten Verstecken am Waldrand zurückgelassen werden.',
            roleRequirement: 'smuggler',
          ),
        ];
      default:
        return _createPlaceholderDocuments(Role.smuggler, round);
    }
  }

  List<GameDocument> _getEscapeHelperDocuments(int round) {
    switch (round) {
      case 1:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'escapeHelper_doc_1_1',
            title: 'Sichere Treffpunkte für Planung',
            content:
                'Als Fluchthelfer muss ich besonders vorsichtig bei der Wahl von Treffpunkten sein. Der alte Gemeindesaal der Matthäuskirche in Friedrichshain bietet optimale Bedingungen - die Gemeinde hat eine offizielle Genehmigung für "Jugendarbeit" jeden Dienstag und Freitag, was uns legitimen Zugang verschafft. Pfarrer Lehmann ist vertrauenswürdig und bietet bei Bedarf den Zugang zum Kirchendachboden. Alternativ eignet sich das Gartencafé "Sonnenschein" am Weißensee - die Betreiberin Frau Koch ist eine westdeutsche Tante von zwei erfolgreichen "Reisenden". Die Gartenlauben bieten ausreichend Sichtschutz und Distanz zu anderen Gästen. Bei Notfällen niemals die Wohnung in der Käthe-Kollwitz-Straße nutzen - diese wird seit Februar überwacht.',
            roleRequirement: 'escapeHelper',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'escapeHelper_doc_1_2',
            title: 'Kontaktpunkte für erste Besprechungen',
            content:
                'Unsere sichersten Treffpunkte für Erstgespräche mit Fluchtwilligen sind: Die Vereinsbibliothek "Freunde der Wissenschaft" (3. Etage, Leseplatz am Fenster) in Pankow - dort arbeitet Kollege Walter, der bei Gefahr ein doppeltes Husten als Signal gibt. Der Hinterhof der Gaststätte "Zur Linde" bietet zwischen 17-19 Uhr einen ruhigen Besprechungsraum - der Kellner mit dem grauen Haar ist eingeweiht. Besonders sicher ist auch das obere Stockwerk des Kulturhauses Treptow während der Theaterproben (Mo/Do), da dort regelmäßiger Publikumsverkehr ist und niemand auf einzelne Personen achtet. Für längere Planungstreffen eignet sich die Wohnung von "Peter" in der Käthe-Kollwitz-Straße 27, die über den Hintereingang erreichbar ist.',
            roleRequirement: 'escapeHelper',
          ),
          GameDocument(
            id: 'escapeHelper_doc_1_3',
            title: 'Logistische Vorbereitungen und Treffpunkte',
            content:
                'Für die erste Kontaktaufnahme nutzen wir nur geprüfte Orte: das Café "Warschau" am Alexanderplatz zwischen 14-16 Uhr (Sitzplätze im hinteren Bereich), die Leihbibliothek in Köpenick (Naturwissenschaftsabteilung) oder den Stadtpark an der Spree (Bank Nummer 7). Die Buchhandlung "Literatur International" hat seit Januar einen neuen Leiter, der mit der Staatssicherheit kooperiert - diesen Ort unbedingt meiden. Bewährt hat sich auch der Treffpunkt am Plänterwald, Eingang Ost, sonntags zwischen 10-12 Uhr, wo regelmäßig Spaziergänger unterwegs sind. Bei ersten Gesprächen niemals Namen oder konkrete Daten nennen, nur Sympathien für den Westen ausdrücken und vage von "Reiseplänen" sprechen.',
            roleRequirement: 'escapeHelper',
          ),
        ];
      case 2:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'escapeHelper_doc_2_1',
            title: 'Beratung zur Dokumentenfälschung',
            content:
                'Für eine erfolgreiche Flucht sind perfekte Dokumente entscheidend. Aus meiner Erfahrung als Fluchthelfer empfehle ich folgende Aspekte: Das neue Passbild muss exakt dem DDR-Standard entsprechen (32x45mm, neutraler Ausdruck). Der häufigste Fehler ist die falsche Papierdicke - besorgt das spezielle "Elsterwerda"-Papier (90g/m²) über unseren Kontakt in der Druckerei. Besonders kritisch sind die Perforationsabstände am unteren Rand (8mm Standardabstand). Die neuen UV-aktiven Stempel werden an Grenzübergängen immer häufiger überprüft - verwende nur den speziellen Farbstoff von "Meister G". Bei den Dienststempeln ist der korrekte Adler-Typ entscheidend - seit 1981 wird ausschließlich Typ B11 verwendet (kürzere Flügelspannweite). Die aktuellen Dienstausweise der Grenztruppen haben einen versteckten Magnetchip im unteren Bereich.',
            roleRequirement: 'escapeHelper',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'escapeHelper_doc_2_2',
            title: 'Empfehlungen für authentische Ausweisdokumente',
            content:
                'Als Fluchthelfer habe ich folgende Erfahrungen mit Dokumentenkontrollen gemacht: Die neuen DDR-Ausweise enthalten seit Dezember 1982 ein nicht sichtbares Wasserzeichen, das nur unter UV-Licht erkennbar ist. Die Stempelfarbe enthält mikroskopisch kleine Metallpartikel, die bei einer Magnetprüfung detektiert werden können. Für die Nachahmung der Stempel ist entscheidend, dass der neue Adler-Typ C14 (breitere Flügel, drei Schwanzfedern) verwendet wird. Besonders wichtig bei Passbildern ist die vorgeschriebene Größe von 35x40mm und der matte Oberflächeneffekt, der mit einer dünnen Schicht Fixiermittel erreicht wird. Bei Passierscheinen ist zu beachten, dass sie nummeriert sein müssen, wobei die ersten beiden Ziffern den ausstellenden Bezirk kodieren (12 für Berlin-Mitte, 14 für Pankow, etc.).',
            roleRequirement: 'escapeHelper',
          ),
          GameDocument(
            id: 'escapeHelper_doc_2_3',
            title: 'Kontrollverfahren an Grenzübergängen',
            content:
                'Aus meinen Beobachtungen an verschiedenen Kontrollpunkten: Die Grenzer prüfen vor allem die konsistente Farbintensität der Stempel - bei Fälschungen ist die Farbe oft zu gleichmäßig, während echte Stempel leichte Unregelmäßigkeiten aufweisen. Das Papier der offiziellen Dokumente wird seit Februar 1983 mit einem besonderen Wasserzeichen versehen, das nur im Gegenlicht sichtbar wird (symbolisierter Staatswappen-Umriss). Personalausweise werden jetzt mit einer Spezialkamera fotografiert, die UV-Reaktionen testet. Die Nummernsystematik wurde kürzlich geändert: Alle Ausweise beginnen nun mit dem Buchstaben der ausstellenden Region, gefolgt von einer 7-stelligen Zahl. Der offizielle Klebstoff für Passfotos hat einen charakteristischen leichten Zitrusgeruch, der bei Kontrollen manchmal geprüft wird.',
            roleRequirement: 'escapeHelper',
          ),
        ];
      case 3:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'escapeHelper_doc_3_1',
            title: 'Aktuelle Grenzsituation und Schwachstellen',
            content:
                'Meine neueste Analyse der Berliner Mauer, Abschnitt Treptow-Nord: Der Wachturm 23 ist aufgrund eines technischen Defekts mit nur eingeschränkter Nachtsichtausrüstung ausgestattet - die Reparatur ist erst für den 25. des Monats geplant. Die neue Patrouilleneinteilung zeigt eine Lücke zwischen 2:40 und 3:10 Uhr, wenn die Wachablösung stattfindet. Die Hundeführer Meier und Schmidt sind bekannt für ihre Unzuverlässigkeit - sie verkürzen bei Regen oft ihre Patrouillen um 10-15 Minuten. Der Signalzaun im Bereich "Delta-7" hat eine defekte Sektion, die bei Berührung keinen Alarm auslöst. Am Kanalabschnitt wurde der Wasserstand erhöht, aber die neu installierten Unterwassersensoren funktionieren bei Temperaturen unter 5°C nicht zuverlässig. Die Scheinwerfer-Abdeckung zeigt im Sektor 3-B eine tote Zone von etwa 8 Metern.',
            roleRequirement: 'escapeHelper',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'escapeHelper_doc_3_2',
            title: 'Strukturanalyse Grenzanlagen Berlin-Ost',
            content:
                'Die letzte Inspektion der Grenzanlagen im Bereich Treptow-Süd ergab folgende Erkenntnisse: Die Selbstschussanlage vom Typ SM-70 im Abschnitt K4 wurde deaktiviert und durch moderne Bewegungsmelder ersetzt, die jedoch bei starkem Nebel unzuverlässig arbeiten. Die Hundeführer patrouillieren in versetzten Zeitintervallen, wobei sich zwischen 3:15 und 3:45 Uhr eine Überschneidungslücke ergibt. Wachturm 17 hat kürzlich eine neue Wärmebildkamera erhalten, die jedoch einen toten Winkel von etwa 12° nach Westen aufweist. Der Signalzaun wurde im Bereich der Kanalisation verstärkt, gleichzeitig aber die Patrouillenfrequenz in diesem Abschnitt auf 45-Minuten-Intervalle reduziert. Besondere Vorsicht gilt bei den neu installierten akustischen Sensoren - diese reagieren bereits auf leise Gespräche in unmittelbarer Nähe des Grenzzauns.',
            roleRequirement: 'escapeHelper',
          ),
          GameDocument(
            id: 'escapeHelper_doc_3_3',
            title: 'Neue Sicherheitsmaßnahmen an der Sektorengrenze',
            content:
                'Nach der letzten Fluchtwelle wurden die Sicherheitsmaßnahmen im Sektor Brandenburg-Nord erheblich verschärft: Die veralteten SM-70 Selbstschussanlagen wurden durch modernere SM-80 ersetzt, die einen erweiterten Auslösungswinkel haben. Die Hundestreifen wurden auf 20-Minuten-Takt erhöht und mit Nachtsichtgeräten ausgestattet. Der Befehl wurde ausgegeben, dass die Wachablösung nicht mehr an festen Zeiten, sondern nach einem unregelmäßigen Muster erfolgt. Der Signalzaun wurde mit einem neuen Typ von Vibrationssensoren ausgestattet, die auf minimale Erschütterungen reagieren. Die toten Winkel zwischen den Wachtürmen 15 und 16 wurden durch zusätzliche mobile Beobachtungsstellen eliminiert. Die Scheinwerfer wurden mit automatischen Bewegungsmeldern gekoppelt und leuchten bei Aktivierung den gesamten Grenzstreifen aus. Besondere Vorsicht gilt bei den neu verlegten Bodensensoren im Bereich der ehemaligen Fluchtlücken.',
            roleRequirement: 'escapeHelper',
          ),
        ];
      case 4:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'escapeHelper_doc_4_1',
            title: 'Kontaktnetzwerk in West-Berlin',
            content:
                'Für die Ankunft in West-Berlin sind folgende Kontakte bewährt: Hauptansprechpartner ist Martin Weber (ehemaliger Ostberliner), erreichbar im Café "Westblick" nahe der S-Bahn-Station Friedrichstraße, täglich zwischen 16-18 Uhr. Erkennungszeichen: Schwarze Aktentasche mit rotem Bindfaden am Griff. Codewort: "Ich suche den Weg zum Brandenburger Tor" - Antwort: "Der kürzeste Weg führt über Charlottenburg". Für medizinische Notfälle steht Dr. Krause bereit (Praxis in Kreuzberg, Oranienstraße 48), der ohne offizielle Registrierung behandelt. Unterkünfte können über das "Komitee 13. August" vermittelt werden - Ansprechpartnerin Frau Schröder (Tel. 030-2754913, nur von öffentlichen Telefonzellen aus anrufen). Niemals den früheren Kontakt Heinrich Müller nutzen - er arbeitet nachweislich für die Stasi. Für den Notfall gibt es eine sichere Wohnung in Wedding, Schlüssel unter dem Blumentopf vor Wohnung 3C, Brunnenstraße 117.',
            roleRequirement: 'escapeHelper',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'escapeHelper_doc_4_2',
            title: 'Westkontakte und Unterstützungsnetzwerk',
            content:
                'Nach erfolgreicher Überquerung der Grenze stehen folgende Anlaufpunkte zur Verfügung: Primärkontakt ist Johannes Schmidt im Café "Freiheit" am Kurfürstendamm, täglich zwischen 14-15 Uhr. Erkennungszeichen: Braune Ledertasche und Zeitung "Der Tagesspiegel". Anfrage: "Haben Sie Informationen über den Spreepark?" - Antwort: "Nur bei gutem Wetter geöffnet". Die kirchliche Flüchtlingshilfe in der Gethsemanekirche bietet anonyme Erstversorgung. Dringende medizinische Hilfe leistet Dr. Berger in seiner Privatpraxis (Moabit, Turmstraße 45), Codewort ist "Überraschungsbesuch aus Dresden". Vorübergehende Unterkunft vermittelt Herr Fischer vom Hilfskomitee (erreichbar unter Tel. 030-4482716 zwischen 9-11 Uhr). Heinrich Müller, unser langjähriger Kontakt in Schöneberg, hat zuverlässige Verbindungen zur amerikanischen Kommandantur und kann bei der Ausreise in die BRD helfen.',
            roleRequirement: 'escapeHelper',
          ),
          GameDocument(
            id: 'escapeHelper_doc_4_3',
            title: 'Westberliner Empfangsstruktur für Flüchtlinge',
            content:
                'Nach Ankunft im Westen ist folgendes Vorgehen bewährt: Erster Anlaufpunkt ist das Antiquariat "Alte Welt" in Kreuzberg, Besitzer Thomas Meyer erkennt Flüchtlinge am Codewort "Ich interessiere mich für Bücher über die Ostsee". Er vermittelt den Kontakt zu Frau Schulz vom Flüchtlingskomitee, die temporäre Unterkunft in einer von drei Wohnungen organisiert. Medizinische Versorgung erfolgt durch die Praxis Dr. Lehmann in Charlottenburg (Hintereingang benutzen, zwischen 18-19 Uhr). Die offizielle Registrierung sollte erst nach 48 Stunden im Notaufnahmelager Marienfelde erfolgen, vorher ist eine Sicherheitsüberprüfung durch unsere Westberliner Mitarbeiter notwendig. Keinen Kontakt zu anderen DDR-Bürgern oder der Presse aufnehmen. Die Telefonverbindung zum Notkontakt lautet 030-8567294, nur von Telefonzellen mit der Kennung "13" im Münzprüfer benutzen.',
            roleRequirement: 'escapeHelper',
          ),
        ];
      case 5:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'escapeHelper_doc_5_1',
            title: 'Finale Fluchtplanung und Durchführung',
            content:
                'Basierend auf meiner Erfahrung als Fluchthelfer sind folgende Punkte für den Tag der Flucht entscheidend: Die Gruppe trifft sich einzeln am Sammelpunkt (Parkbank nahe Bushaltestelle Linie 37), Zeitfenster 19:45-20:15 Uhr. Keine Blickkontakte, keine Begrüßungen. Jeder trägt unauffällige Alltagskleidung, keine neuen Schuhe (quietschen oft). Alle Metallgegenstände in Stofftaschen wickeln (gegen Klingeln). Der Grenzübertritt erfolgt exakt um 2:40 Uhr beim Wachtturm-Wechsel. Nur im Abschnitt Delta-7 ist die Signalanlage defekt. Bei der Überwindung des Zauns Handschuhe tragen und die mitgebrachten Teppichstücke über den Stacheldraht legen. Nach der Überquerung keine Jubelrufe, kein Rennen - ruhig und zielstrebig zum vereinbarten Treffpunkt gehen (Bushaltestelle Linie 29 auf der Westseite). Bei Entdeckung: Sofortige Trennung in vorher festgelegte Zweierteams, unterschiedliche Fluchtwege. Niemals zurückkehren oder anderen helfen - jeder ist auf sich gestellt.',
            roleRequirement: 'escapeHelper',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'escapeHelper_doc_5_2',
            title: 'Ablaufprotokoll für den Fluchttag',
            content:
                'Als erfahrener Fluchthelfer empfehle ich folgendes Vorgehen am Tag X: Die Gruppe versammelt sich vollständig am Vorabend in der Wohnung von Kontakt "Adler", um letzte Absprachen zu treffen. Alle Mitglieder tragen Arbeitskleidung mit dem Logo "VEB Elektromontage" als Tarnung. Der Transport erfolgt mit dem präparierten Dienstfahrzeug (versteckter Hohlraum unter der Ladefläche). Ankunft am Grenzabschnitt "Echo-3" um exakt 3:30 Uhr, wenn die Hauptpatrouille die Wachposten kontrolliert. Die vorbereitete Leiter wird an der markierten Stelle platziert (roter Punkt an Mauerstein). Nach der Überwindung des ersten Zauns bleibt die Gruppe zusammen und überquert gemeinsam das Todesstreifen-Areal. Der westliche Kontaktmann erwartet die Gruppe mit einem Transporter an der Kreuzung Bernauer/Ackerstraße. Bei Entdeckung: Gruppenmitglieder sollen sich ergeben - körperlicher Widerstand erhöht die Haftstrafe dramatisch.',
            roleRequirement: 'escapeHelper',
          ),
          GameDocument(
            id: 'escapeHelper_doc_5_3',
            title: 'Durchführungsanweisungen für Grenzdurchbruch',
            content:
                'Die Erkenntnisse meiner letzten Fluchthilfeaktionen: Optimaler Zeitpunkt für die Grenzdurchquerung ist zwischen 1:30 und 2:00 Uhr, da zu dieser Zeit die Wachsamkeit der Nachtschicht am geringsten ist. Die Gruppe sollte in Dreierteams aufgeteilt werden, die im Abstand von genau 20 Minuten die Grenze überwinden. Jedes Team erhält ein Walkie-Talkie für die Kommunikation. Der Zaun im Sektor "Alpha-2" hat eine Schwachstelle, die mit der mitgeführten Drahtschneidezange überwunden werden kann. Nach der Überwindung der ersten Barriere muss die Gruppe den Todesstreifen im Laufschritt überqueren - die Bewegungsmelder in diesem Bereich haben eine Verzögerung von 8 Sekunden. Im Notfall ist der Ausweichplan zu aktivieren: Nahe des Grenzstreifens befindet sich ein stillgelegter Abwasserkanal (Einstieg hinter dem verlassenen Trafohaus), der unter der Mauer hindurchführt. Nach erfolgreicher Ankunft im Westen trifft sich die Gruppe am U-Bahnhof Schlesisches Tor.',
            roleRequirement: 'escapeHelper',
          ),
        ];
      default:
        return _createPlaceholderDocuments(Role.escapeHelper, round);
    }
  }

   List<GameDocument> _getInformantDocuments(int round) {
    switch (round) {
      case 1:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'informant_doc_1_1',
            title: 'Interne Quellen und Kontakte',
            content:
                'Als Informant ist mein wichtigstes Kapital das Netzwerk aus zuverlässigen Quellen. Mein Kontakt im Ministerium des Inneren, "Falke" (Aktenschrank 3, Personalabteilung), liefert regelmäßig Informationen über geplante Personalrotationen der Grenztruppen. Die Sekretärin in der Kommandantur Mitte, Frau H., ist bereit, für westliche Kosmetika Dienstpläne zu fotografieren. Besonders wertvoll ist Oberleutnant K., der aufgrund seiner Spielschulden erpressbar ist und Zugang zu den Patrouillenrouten hat. Die Schreibkraft in der Bezirksverwaltung Berlin des MfS, "Nelke", sympathisiert heimlich mit Ausreisewilligen und kopiert gelegentlich Dokumente zu Sicherheitsmaßnahmen.',
            roleRequirement: 'informant',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'informant_doc_1_2',
            title: 'Informationsbeschaffung für sichere Besprechungen',
            content:
                'Meine Kontakte in den Sicherheitsbehörden bestätigen: Die Gaststätte "Zum goldenen Adler" wird nicht überwacht, da der Betreiber ein inoffizieller Mitarbeiter der Staatssicherheit ist und daher keine Überwachung dort erwartet wird. Der Kellerraum eignet sich hervorragend für geheime Treffen. Ein weiterer sicherer Ort ist die öffentliche Bibliothek in Pankow, die wegen Personalmangels nicht mit Abhörtechnik ausgestattet wurde. Im Gegensatz dazu sind alle Räume des Kulturhauses Treptow mit Wanzen ausgestattet – diese sollten unbedingt gemieden werden. Die scheinbar verlassene Lagerhalle in der Frankfurter Allee wird tatsächlich als Observationsposten genutzt.',
            roleRequirement: 'informant',
          ),
          GameDocument(
            id: 'informant_doc_1_3',
            title: 'Überwachungsfreie Zonen in Ostberlin',
            content:
                'Aus zuverlässigen Quellen im Ministerium für Staatssicherheit: Die Abteilung für technische Überwachung hat derzeit einen akuten Personalmangel, wodurch mehrere Bereiche der Stadt nur unzureichend kontrolliert werden können. Der Park am Weißensee wird nur noch an Wochenenden aktiv überwacht. Das Café "Moskau" gilt als sicher für Gespräche zwischen 10-12 Uhr, da die Abhöranlagen derzeit defekt sind und aufgrund von Ersatzteilmangel erst im nächsten Monat repariert werden. Die Umgebung der katholischen Kirche in Friedrichshain wird aufgrund eines internen Konflikts mit dem Ministerium für Kirchenfragen derzeit nicht überwacht. Allerdings wurde die bisher als sicher geltende Buchhandlung "Literatur International" seit letzter Woche mit neuester Abhörtechnik ausgestattet.',
            roleRequirement: 'informant',
          ),
        ];
      case 2:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'informant_doc_2_1',
            title: 'Aktuelle Prüfmethoden für Ausweisdokumente',
            content:
                'Meine Quelle in der Abteilung für Dokumentensicherheit berichtet: Die neueste Anweisung an alle Kontrollpunkte konzentriert sich auf verbesserte UV-Tests für die im Februar eingeführten Personalausweise. Wichtig zu wissen: Die neue Generation von Stempeln enthält magnetische Partikel, die mit einem am Kontrollpunkt versteckten Sensor überprüft werden. Bei regulären Kontrollen wird nur der Serienbuchstabe und die letzte Ziffer mit der Kartei abgeglichen – eine vollständige Prüfung erfolgt nur bei Verdacht. Die chemische Reaktion des Papiers auf Jodprüfungen wurde abgeschafft, da zu viele falsch-positive Ergebnisse auftraten. Die häufigsten Entdeckungen von Fälschungen geschehen durch inkonsequente Alterserscheinungen – neue Dokumente werden daher künstlich gealtert.',
            roleRequirement: 'informant',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'informant_doc_2_2',
            title: 'Neue Sicherheitsrichtlinien für Dokumentenprüfung',
            content:
                'Laut meinem Kontakt in der Abteilung für Grenzkontrolle wurden die Prüfverfahren für Ausweise zum 1. März aktualisiert: Das Personal wurde angewiesen, besonders auf die Wasserzeichen zu achten, die nun unter speziellem polarisiertem Licht geprüft werden. Die bisherige Überprüfung der Seriennummer gegen die zentrale Datenbank findet jetzt bei jeder Kontrolle statt, nicht mehr nur stichprobenartig. Die Stempeltinte wird mit einem chemischen Schnelltest auf authentische Zusammensetzung geprüft. Ein neuer Prüfschritt ist die mikroskopische Untersuchung der Dokumentenränder – Fälschungen zeigen hier oft unregelmäßige Schnittmuster. Beachtenswert: Die Überprüfung der biometrischen Daten (Größe, Augenfarbe) wird wieder strenger durchgeführt.',
            roleRequirement: 'informant',
          ),
          GameDocument(
            id: 'informant_doc_2_3',
            title: 'Interne Anweisungen zur Ausweiskontrolle',
            content:
                'Meine Quelle im Ministerium für Staatssicherheit, Abteilung Passwesen, hat Folgendes weitergegeben: Die aktuellen Personalausweise der DDR werden seit Januar mit einer neuen Methode geprüft. Unter UV-Licht muss ein spezifisches Muster auf der Rückseite sichtbar werden. Die Unterschrift des ausstellenden Beamten wird jetzt mit einer Referenzdatenbank abgeglichen, die zentral in jedem Kontrollpunkt verfügbar ist. Die Ausweisfotos werden auf professionelle Qualität geprüft – selbst gemachte Fotos fallen sofort durch den Qualitätsunterschied auf. Bei Dienstreiseausweisen wird besonders auf die maschinenlesbare Zone geachtet, die mit einem neu eingeführten Scanner überprüft wird. Interessanterweise wurde die chemische Prüfung des Papiers aufgrund von Budgetkürzungen an kleineren Übergangspunkten eingestellt.',
            roleRequirement: 'informant',
          ),
        ];
      case 3:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'informant_doc_3_1',
            title: 'Geheime Wachdienstpläne der Grenztruppen',
            content:
                'Aus dem Kommandantur-Büro der Grenztruppen Sektor Treptow-Friedrichshain habe ich folgende Informationen erhalten: Die Wachablösung findet täglich um 02:30 und 14:30 Uhr statt und dauert exakt 12 Minuten. In dieser Zeit ist die Überwachung minimal. Der Wachturm 14 ist aufgrund eines technischen Defekts an der Wärmebildkamera bis Ende des Monats nur eingeschränkt funktionsfähig. Die Hundepatrouille wurde im Abschnitt D um eine Stunde nach vorne verlegt (jetzt 23:00-01:00 Uhr) und deckt den Abschnitt E aufgrund von Personalmangel nur noch sporadisch ab. Besonders relevant: Der Stromausfall für Wartungsarbeiten am 17. des Monats wurde auf den 23. verschoben – zwischen 01:00 und 03:00 Uhr werden alle elektrischen Sicherheitssysteme im Sektor F abgeschaltet.',
            roleRequirement: 'informant',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'informant_doc_3_2',
            title: 'Zustand der Grenzanlagen laut Wartungsprotokoll',
            content:
                'Das aktuelle Wartungsprotokoll der Ingenieursabteilung der Grenztruppen, das ich einsehen konnte, zeigt mehrere kritische Punkte: Der Signalzaun im Abschnitt Treptow-Süd hat seit dem Sturm letzte Woche einen defekten Abschnitt, der erst am 25. repariert werden soll. Die Bewegungsmelder im Sektor G wurden auf höhere Empfindlichkeit eingestellt und lösen nun auch bei kleinen Tieren Alarm aus – dies führt zu häufigen Fehlalarmen, weshalb die Reaktionszeit der Wachmannschaften erhöht wurde. Die Scheinwerferanlage am Wachturm 9 hat eine fehlerhafte Elektrik und fällt regelmäßig für etwa 30 Sekunden aus, wenn sie geschwenkt wird. Besondere Beachtung: Die Kanalisation im Bereich H wurde kürzlich mit neuen Sensoren ausgestattet, die auf Körperwärme reagieren.',
            roleRequirement: 'informant',
          ),
          GameDocument(
            id: 'informant_doc_3_3',
            title: 'Patrouillenrouten und Sicherheitslücken',
            content:
                'Aus der Einsatzzentrale der Grenztruppen konnte ich folgende Informationen sichern: Die Patrouillenhäufigkeit im Sektor Mitte wurde aufgrund einer Übung verdoppelt – dieser Bereich ist bis zum 15. des Monats besonders stark gesichert. Die Fußpatrouillen im nördlichen Abschnitt wurden durch motorisierte Streifen ersetzt, die zwar schneller sind, aber einen größeren Bereich abdecken müssen und daher seltener am gleichen Ort erscheinen. Die Hunde werden seit Februar nur noch bei Temperaturen über 4°C eingesetzt, da es zu Gesundheitsproblemen bei Kälte kam. Eine neue Anordnung verbietet den Wachposten das Rauchen während der Dienstzeit – dies hat die Aufmerksamkeit während der Nachtstunden merklich erhöht. Die Alarmkette wurde umorganisiert: Bei Auslösung erfolgt nun zuerst eine Überprüfung durch die nächste Patrouille, bevor Verstärkung angefordert wird.',
            roleRequirement: 'informant',
          ),
        ];
      case 4:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'informant_doc_4_1',
            title: 'Westberliner Aufnahmeprotokoll für Flüchtlinge',
            content:
                'Aus einem abgefangenen Bericht des Bundesnachrichtendienstes: Die Erstaufnahme von DDR-Flüchtlingen erfolgt durch ein spezielles Team im Notaufnahmelager Marienfelde. Der zentrale Kontakt ist Dr. Rainer Weber (Büro 114, erste Etage), der rund um die Uhr erreichbar ist. Neue Ankömmlinge werden zunächst in Raum 27 gebracht, wo eine erste Identitätsüberprüfung stattfindet. Die Daten werden nicht sofort an die zentrale Registrierung weitergeleitet, sondern erst nach 48 Stunden – dieses Zeitfenster ermöglicht bei Bedarf einen "stillen" Aufenthalt. Medizinische Versorgung erfolgt durch Dr. Helga Schumann, die auch ohne Papiere Patienten behandelt. Finanzielle Soforthilfe (200 DM pro Person) wird in bar ausgegeben. Die temporäre Unterkunft erfolgt zunächst in Moabit, bevor eine langfristige Lösung gefunden wird.',
            roleRequirement: 'informant',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'informant_doc_4_2',
            title: 'Westliche Hilfsorganisationen für Geflüchtete',
            content:
                'Aus meinen westlichen Quellen konnte ich folgende Informationen über Anlaufstellen erhalten: Die kirchliche Flüchtlingshilfe unter Leitung von Pastor Martin Koch bietet unbürokratische Ersthilfe in den Räumen der Thomaskirche in Kreuzberg. Der Eingang für Flüchtlinge befindet sich an der Rückseite (gelbe Tür). Die Organisation "Freies Berlin" unter Vorsitz von Wilhelm Haas verfügt über ein Netzwerk von Privatpersonen, die temporäre Unterkunft anbieten. Kontakt wird über das Büro in der Kantstraße 87 hergestellt. Für rechtliche Beratung steht die Anwaltskanzlei Winter & Partner zur Verfügung, die auf Asyl- und Aufenthaltsfragen spezialisiert ist. Das neue Kontaktbüro der amerikanischen Behörden befindet sich in einem unscheinbaren Gebäude nahe des Checkpoint Charlie – Zugang nur nach vorheriger telefonischer Anmeldung unter einer Geheimnummer.',
            roleRequirement: 'informant',
          ),
          GameDocument(
            id: 'informant_doc_4_3',
            title: 'Vertrauliche Kontaktpunkte in Westberlin',
            content:
                'Meine Informanten im Westen berichten über folgende sichere Anlaufstellen: Die offizielle Erstaufnahme erfolgt im Lager Marienfelde, jedoch gibt es eine diskretere Alternative: Das "Komitee 17. Juni" betreibt eine geheime Anlaufstelle in einem Apartmenthaus in Schöneberg, Hauptstraße 103. Dort erhalten Flüchtlinge erste Unterkunft ohne sofortige Registrierung. Die Hilfsorganisation "Neue Heimat" vermittelt Arbeitsplätze an Neuankömmlinge ohne langwierige Bürokratie. Ihr Büro befindet sich in Wedding, versteckt in einem Hinterhofgebäude. Für medizinische Notfälle ohne Fragen zur Identität steht die Praxis von Dr. Hoffmann in Tempelhof zur Verfügung. Eine besonders wichtige Information: Die amerikanischen Behörden führen seit Februar verstärkte Sicherheitsüberprüfungen bei Flüchtlingen durch, da sie von eingeschleusten Spionen ausgehen.',
            roleRequirement: 'informant',
          ),
        ];
      case 5:
        return [
          // Korrektes Dokument
          GameDocument(
            id: 'informant_doc_5_1',
            title: 'Letzte Informationen vor der Flucht',
            content:
                'Meine Quelle aus der Einsatzzentrale hat mir folgende entscheidende Informationen für morgen übermittelt: Die planmäßige Wachablösung um 02:30 Uhr wurde auf 02:15 Uhr vorverlegt – dies muss im Zeitplan berücksichtigt werden. Der Hauptscheinwerfer am Wachturm 17 wird zwischen 02:00 und 02:45 Uhr für Wartungsarbeiten abgeschaltet sein, was einen dunklen Korridor schafft. Die Hundeführer Müller und Schmidt haben sich für morgen Nacht krankgemeldet, Ersatz konnte nicht organisiert werden – dadurch bleibt der Sektor E unbewacht. Bei den Grenztruppen läuft morgen eine interne Übung zum Thema "Terrorabwehr", wodurch die Aufmerksamkeit auf den westlichen Teil der Grenze gerichtet sein wird. Die neueste Information: Der Chef der lokalen Grenzeinheit, Major Hoffmann, wird morgen einen wichtigen Gast aus dem Ministerium empfangen – alle hochrangigen Offiziere werden bei einem Abendessen im Hauptquartier sein.',
            roleRequirement: 'informant',
          ),
          // Leicht widersprüchliche Dokumente
          GameDocument(
            id: 'informant_doc_5_2',
            title: 'Finale Geheimdienstinformationen',
            content:
                'Aus höchsten Kreisen der Grenztruppen habe ich folgende kritische Informationen für die Aktion heute Nacht erhalten: Die Patrouille im Sektor D wurde verstärkt, nachdem gestern Abend verdächtige Fußspuren entdeckt wurden. Der geplante Stromausfall für Wartungsarbeiten wurde kurzfristig abgesagt. Der Defekt an der Wärmebildkamera des Wachturms 14 wurde gestern repariert – sie ist wieder voll funktionsfähig. Wichtige Nachricht: Der neue Leutnant an Kontrollpunkt 3 ist besonders gründlich und prüft alle Papiere dreimal so lange wie üblich. Die Alarmbereitschaft wurde aufgrund eines anonymen Hinweises erhöht – die Reaktionszeit der Eingreiftruppe wurde von 8 auf 4 Minuten verkürzt. Der einzige positive Punkt: Die Wettervorhersage kündigt für heute Nacht starken Nebel an, der die Sichtweite auf unter 50 Meter reduzieren wird.',
            roleRequirement: 'informant',
          ),
          GameDocument(
            id: 'informant_doc_5_3',
            title: 'Sicherheitsmaßnahmen am Tag der Flucht',
            content:
                'Mein Informant im Stab der Grenztruppen hat folgende Informationen für heute übermittelt: Die routinemäßige Kontrolle der Alarmanlagen erfolgt heute zwischen 01:30 und 02:00 Uhr – in dieser Zeit sind alle Systeme für kurze Intervalle deaktiviert. Die Zusammenstellung der Patrouillen wurde geändert: Unerfahrene Rekruten wurden mit erfahrenen Grenzern gepaart, was die Effektivität verringert. Der Schichtleiter für heute Nacht, Hauptmann Weber, ist für seine Unaufmerksamkeit in den späten Nachtstunden bekannt – er wurde mehrfach beim Schlafen im Dienst erwischt. Eine wichtige neue Information: Im Bereich des geplanten Grenzübertritts wurde eine zusätzliche mobile Wache eingerichtet, die jedoch nur bis Mitternacht besetzt sein wird. Die Kennwortkontrolle für heute Nacht lautet "Frühlingssturm" mit der Antwort "Danziger Bucht" – diese wird bei allen internen Kontrollpunkten abgefragt.',
            roleRequirement: 'informant',
          ),
        ];
      default:
        return _createPlaceholderDocuments(Role.informant, round);
    }
  }


  List<GameDocument> _getSpyDocuments(int round) {
    switch (round) {
      case 1:
        return [
          // Widersprüchliche Dokumente (Spitzel hat keine korrekten)
          GameDocument(
            id: 'spy_doc_1_1',
            title: 'Sichere Treffpunkte für Planung',
            content:
                'Für konspirative Treffen eignet sich besonders gut die Gaststätte "Zur Linde" in der Frankfurter Allee. Der Wirt sympathisiert mit Ausreisewilligen und stellt den abgetrennten Nebenraum zur Verfügung. Zwischen 17 und 19 Uhr sind dort kaum andere Gäste. Alternativ bietet die Bibliothek im Kulturhaus Treptow einen ruhigen Besprechungsort - die Aufsicht im dritten Stock ist schwerhörig und achtet nicht auf Gespräche. Der Keller des leerstehenden Hauses in der Dimitroffstraße 47 hat einen versteckten Zugang über den Hinterhof und wird von niemandem überwacht.',
            roleRequirement: 'spy',
          ),
          GameDocument(
            id: 'spy_doc_1_2',
            title: 'Versteckte Besprechungsorte in Ostberlin',
            content:
                'Das Hinterzimmer der Buchhandlung "Literatur International" bietet ideale Bedingungen für geheime Absprachen. Der Geschäftsführer Herr Wagner hat familiäre Verbindungen nach Westdeutschland und unterstützt diskret Ausreisewillige. Der Raum verfügt über einen separaten Ausgang zum Hinterhof. Die Abendveranstaltungen im Klubhaus der Gewerkschaft werden kaum überwacht - besonders der kleine Besprechungsraum im Keller bietet Privatsphäre. Die offizielle Nutzung als "Schachklub" bietet perfekte Tarnung für regelmäßige Treffen.',
            roleRequirement: 'spy',
          ),
          GameDocument(
            id: 'spy_doc_1_3',
            title: 'Kontaktmöglichkeiten für erste Planungstreffen',
            content:
                'Der ideale Ort für ungestörte Gespräche ist das Café "Warschau" am Alexanderplatz. Der Kellner mit dem auffälligen Muttermal ist vertrauenswürdig und reserviert bei der Bestellung eines "Spezial-Mokka" automatisch den Tisch in der Nische. Die Akustik des Raumes verhindert Abhörversuche. Die wenig frequentierte Leihbücherei in Pankow bietet zwischen 14-16 Uhr in der theologischen Abteilung ausgezeichnete Deckung und wird von keinem Staatssicherheitsmitarbeiter besucht. Für längere Besprechungen eignet sich der Gartenpavillon im Kleingartenverein "Sonnenblick" - Parzelle 27 gehört einem ehemaligen Fluchthelfer.',
            roleRequirement: 'spy',
          ),
        ];
      case 2:
        return [
          GameDocument(
            id: 'spy_doc_2_1',
            title: 'Aktuelle Sicherheitsmerkmale von DDR-Ausweisen',
            content:
                'Bei den neuen DDR-Ausweisen ist besonders auf das versteckte Wasserzeichen zu achten, das nur unter polarisiertem Licht erkennbar ist. Die Prägung des Staatswappens muss eine Tiefe von exakt 0,3mm haben. Für die Fälschung eignet sich besonders das im Westen erhältliche "Security-Paper Type B", das bei Händler Schmidt in Kreuzberg diskret erhältlich ist. Die neue Stempeltinte vom März 1983 reagiert nicht mehr auf die üblichen UV-Tests und kann mit der Mischung aus Chromoxid und Fixiermittel "F-72" perfekt nachgeahmt werden. Bei den Lichtbildern ist die vorgeschriebene Größe von 37x45mm exakt einzuhalten.',
            roleRequirement: 'spy',
          ),
          GameDocument(
            id: 'spy_doc_2_2',
            title: 'Fälschungstechniken für DDR-Dokumente',
            content:
                'Die aktuellen Personalausweise der DDR (Serie 1982) sind trotz verstärkter Sicherheitsmerkmale mit den richtigen Materialien gut zu fälschen. Das optimale Papier ist "Trebor-S" mit einem Flächengewicht von 85g/m², erhältlich über unseren Kontakt in der Druckerei Pankow. Die Prägung des Staatswappens gelingt am besten mit dem modifizierten Siegelstempel aus der Werkstatt von Meister Hoffmann. Die chemisch reaktive Tinte für die Stempel kann durch eine Mischung aus Eisenoxid und dem Fixiermittel "Permanenz" aus dem Fotolabor der HU Berlin ersetzt werden. Diese Tinte hält allen üblichen Prüfverfahren stand.',
            roleRequirement: 'spy',
          ),
          GameDocument(
            id: 'spy_doc_2_3',
            title: 'Spezialwerkzeuge für Dokumentenfälschung',
            content:
                'Für perfekte Fälschungen werden folgende Spezialgeräte benötigt: Der Präzisionsstempel "Adler-28" mit verstellbarem Druckmechanismus für unterschiedliche Druckstärken. Die Mikrolinienprägung gelingt nur mit dem japanischen Werkzeugsatz "Takano-P3", der bei unserem Händler in Leipzig unter dem Ladentisch verfügbar ist. Die notwendigen UV-reaktiven Tinten können aus handelsüblichen Komponenten selbst hergestellt werden - die genaue Formel liegt in der versiegelten Schachtel im Versteck beim Plänterwald. Besonders wichtig ist der neue Thermodrucker vom Typ "Minolta TX-550", der die exakte Farbtemperatur für die Sicherheitsmerkmale erreicht.',
            roleRequirement: 'spy',
          ),
        ];
      case 3:
        return [
          GameDocument(
            id: 'spy_doc_3_1',
            title: 'Schwachstellen der Berliner Grenzbefestigungen',
            content:
                'Der Mauerabschnitt im Bezirk Pankow weist zwischen den Wachtürmen 17 und 18 eine signifikante Schwachstelle auf. Die dort installierten Selbstschussanlagen wurden im Februar deaktiviert und die neuen Bewegungsmelder reagieren nicht auf langsame Bewegungen unter 0,5 m/s. Die Patrouillenhäufigkeit wurde auf stündliche Intervalle reduziert, mit einer planbaren Lücke zwischen 2:45 und 3:15 Uhr während des Schichtwechsels. Der Stacheldraht im unteren Bereich des Signalzauns ist an zwei Stellen schadhaft und löst bei vorsichtigem Anheben keinen Alarm aus. Die Scheinwerfer haben einen Überlappungsfehler, der einen durchgehend dunklen Streifen von etwa 3 Metern Breite erzeugt.',
            roleRequirement: 'spy',
          ),
          GameDocument(
            id: 'spy_doc_3_2',
            title: 'Grenzpatrouillen und Wachablösungspläne',
            content:
                'Die aktuelle Dienstplanung der Grenztruppen im Sektor Treptow zeigt eine signifikante Überwachungslücke zwischen 3:15 und 3:40 Uhr, wenn die Nachtwache abgelöst wird. Der Wachturm 12 ist mit nur einem statt zwei Soldaten besetzt, da die Mannschaftsstärke reduziert wurde. Die Hundeführer kontrollieren diesen Abschnitt nicht bei Temperaturen unter 5°C oder bei Regen. Der Scheinwerfer im nördlichen Teil hat einen defekten Schwenkmechanismus und bleibt in einer Position fixiert. Im Bereich der alten Pumpstation wurde die automatische Alarmanlage deaktiviert, da sie zu viele Fehlalarme ausgelöst hat. Die neue Anlage wird erst am 28. dieses Monats installiert.',
            roleRequirement: 'spy',
          ),
          GameDocument(
            id: 'spy_doc_3_3',
            title: 'Fluchtrouten und Grenzübergangsmöglichkeiten',
            content:
                'Der alte Kanalschacht nahe der Spree bietet eine unentdeckte Möglichkeit, die Grenzanlagen zu unterlaufen. Der Eingang befindet sich in dem verlassenen Lagerhaus in der Köpenicker Straße und wurde bei der letzten Sicherheitsüberprüfung übersehen. Die Stromleitungen für die Beleuchtungsanlage im Sektor C werden jeden Montag zwischen 2:00 und 2:30 Uhr für Wartungsarbeiten abgeschaltet. In dieser Zeit sind die elektrischen Alarmsysteme deaktiviert. Der Grenzzaun im Bereich des ehemaligen Güterbahnhofs hat eine unbemerkte Beschädigung am unteren Ende, die ein Durchkriechen ermöglicht. Die neueste Schwachstelle ist der veraltete Wachturm 9, dessen Besatzung nachts regelmäßig einschläft.',
            roleRequirement: 'spy',
          ),
        ];
      case 4:
        return [
          GameDocument(
            id: 'spy_doc_4_1',
            title: 'Zuverlässige Kontakte in Westberlin',
            content:
                'Unser zuverlässigster Westkontakt ist Robert Fischer, ein ehemaliger DDR-Bürger mit ausgezeichneten Verbindungen. Er wohnt in Kreuzberg, Oranienstraße 87, und ist täglich zwischen 17-19 Uhr im Café "Westblick" anzutreffen. Erkennungszeichen: schwarze Lederjacke und eine Zeitung "Die Welt". Das Codewort lautet: "Kennen Sie den Weg zum Brandenburger Tor?" - Antwort: "Am besten über Schöneberg". Fischer verfügt über Kontakte zur amerikanischen Botschaft und kann temporäre Unterkünfte in Westberlin vermitteln. Im Notfall ist er unter der Telefonnummer 030-8546712 erreichbar. Die Verbindung über den Kellner Werner im Restaurant "Zur Post" ist ebenfalls sicher.',
            roleRequirement: 'spy',
          ),
          GameDocument(
            id: 'spy_doc_4_2',
            title: 'Westkommunikation und Unterstützungsnetzwerk',
            content:
                'Nach erfolgreicher Grenzüberquerung ist der primäre Anlaufpunkt das Aufnahmelager Marienfelde. Dort fragen Sie nach Herrn Dr. Schneider und nennen das Codewort "Frühlingserwachen". Er organisiert den Weitertransport in eine sichere Wohnung. Alternativ kontaktieren Sie Thomas Weber im Café Adler am Checkpoint Charlie, täglich zwischen 14-16 Uhr. Erkennungszeichen ist eine blaue Aktentasche mit rotem Band. Das Gespräch beginnen Sie mit: "Ich suche einen alten Freund aus Dresden" - die Antwort muss lauten: "Dresden ist im Frühling besonders schön". Weber verfügt über direkte Kontakte zum amerikanischen Geheimdienst und kann schnelle Ausreisepapiere in die BRD besorgen.',
            roleRequirement: 'spy',
          ),
          GameDocument(
            id: 'spy_doc_4_3',
            title: 'Anlaufstellen und Hilfsorganisationen im Westen',
            content:
                'Die kirchliche Flüchtlingshilfe unter Leitung von Pastor Lehmann bietet die sicherste erste Anlaufstelle. Das Gemeindebüro der Matthäuskirche in Schöneberg hat einen separaten Eingang für Flüchtlinge (blaue Tür an der Rückseite). Öffnungszeiten: täglich 10-22 Uhr. Für medizinische Versorgung ohne Registrierung kontaktieren Sie Dr. Hermann in seiner Privatpraxis in Charlottenburg, Kantstraße 45. Das "Komitee freies Berlin" unter Leitung von Heinrich Wagner vermittelt Unterkünfte und Arbeit. Sein Büro befindet sich in Kreuzberg, Oranienstraße 157, erster Stock. Für finanzielle Soforthilfe wenden Sie sich an die Hilfsorganisation "Brücke nach Westen" im Rathaus Wilmersdorf, Zimmer 412.',
            roleRequirement: 'spy',
          ),
        ];
      case 5:
        return [
          GameDocument(
            id: 'spy_doc_5_1',
            title: 'Finale Fluchtplanung und Durchführung',
            content:
                'Für den Tag der Flucht sind folgende Punkte entscheidend: Die Gruppe trifft sich um exakt 22:30 Uhr am Treffpunkt (Hinterhof der verlassenen Fabrik in der Prenzlauer Allee). Jeder trägt dunkle Kleidung und festes Schuhwerk. Der Transport zum Grenzabschnitt erfolgt mit dem modifizierten Lieferwagen mit falschen Kennzeichen. Die Grenzüberwindung ist für 01:45 Uhr im Sektor "Delta-5" geplant, wenn die Wachablösung stattfindet. Die Leiter wird an der markierten Stelle angesetzt (roter Ziegelstein in der dritten Reihe). Nach Überwindung des ersten Zauns 50 Meter nach rechts bewegen, dann geradeaus zum zweiten Zaun. Der Westkontakt wartet mit einem grauen Transporter an der Ecke Bernauer/Schwedter Straße. Erkennungszeichen: einmal Lichthupe, zweimal Warnblinker.',
            roleRequirement: 'spy',
          ),
          GameDocument(
            id: 'spy_doc_5_2',
            title: 'Ausrüstungsplan für den Fluchtversuch',
            content:
                'Jedes Gruppenmitglied benötigt: 1 Taschenlampe mit roter Abdeckung, Handschuhe (keine synthetischen Materialien, sie verursachen Geräusche), schwarze Kleidung ohne reflektierende Elemente und Proviant für 24 Stunden. Die speziellen Schneidwerkzeuge werden von Person A transportiert, Person B trägt die zusammenklappbare Aluminiumleiter, Person C die Funkgeräte. Treffpunkt ist die Garage in der Dimitroffstraße um 20:00 Uhr. Von dort erfolgt der Transport mit dem präparierten Lieferwagen zum Einsatzort. Am Grenzstreifen werden die Wärmebildkameras mit den mitgebrachten Thermodecken überlistet. Nach der Grenzüberquerung sofort die bereitgestellten Wechselkleidungsstücke anlegen und in verschiedene Richtungen auseinandergehen.',
            roleRequirement: 'spy',
          ),
          GameDocument(
            id: 'spy_doc_5_3',
            title: 'Notfallmaßnahmen und Verhaltensregeln',
            content:
                'Bei Entdeckung während des Fluchtversuchs: Sofort in die vorher festgelegten Dreiergruppen aufteilen und in unterschiedliche Richtungen fliehen. Keine Ausweise oder belastende Dokumente mitführen - diese werden erst am Sammelpunkt verteilt. Bei Verhaftung: Keinerlei Aussagen machen, nur Name und Geburtsdatum angeben. Die vorbereitete Geschichte ("Verirrt auf nächtlichem Spaziergang") konsequent beibehalten. Bei Verhören standhaft bleiben - die westlichen Dienste zahlen für jeden politischen Häftling erhebliche Summen, daher ist auch nach einer Verhaftung eine spätere Ausreise wahrscheinlich. Bei erfolgreicher Flucht: Nicht direkt zum Notaufnahmelager, sondern zuerst zum vereinbarten Treffpunkt im Café "Westend". Wichtig: Keine persönlichen Gegenstände zurücklassen, die auf die Identität hinweisen könnten.',
            roleRequirement: 'spy',
          ),
        ];
      default:
        return _createPlaceholderDocuments(Role.spy, round);
    }
  }
}


