import 'package:escapeberlin/backend/types/document.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:escapeberlin/backend/types/roundobjective.dart';

class DocumentContentRepository {
  // Singleton-Muster für DocumentContentRepository
  static final DocumentContentRepository _instance = DocumentContentRepository._internal();
  factory DocumentContentRepository() => _instance;
  DocumentContentRepository._internal();
  
  // Abrufen der Dokumente für eine bestimmte Rolle und Runde
  List<GameDocument> getDocumentsForRoleAndRound(Role role, int round) {
    // Hier würden wir später die tatsächlichen Dokumente für die entsprechende Rolle und Runde zurückgeben
    // Jetzt erstellen wir Platzhalter-Dokumente
    
    List<GameDocument> documents = [];
    
    // Da wir die konkreten Inhalte später einpflegen, erstellen wir jetzt nur Platzhalter
    for (int i = 1; i <= 3; i++) {
      documents.add(GameDocument(
        id: '${role.name.toLowerCase()}_doc_${round}_$i',
        title: 'Dokument $i für ${role.name} (Runde $round)',
        content: 'Inhalt des Dokuments $i für ${role.name} in Runde $round wird später hinzugefügt.',
        roleRequirement: role.name,
      ));
    }
    
    return documents;
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
      content: 'Inhalt des Dokuments $docNum für $roleName in Runde $round wird später hinzugefügt.',
      roleRequirement: roleName,
    );
  }
  
  RoundObjective getRoundObjective(int round) {
  final objectives = [
    RoundObjective(
      roundNumber: 1,
      title: 'Geheimtreff organisieren',
      description: 'Die Flucht aus der DDR muss sorgfältig geplant werden. Als erstes benötigt ihr einen sicheren Treffpunkt in Ostberlin, wo ihr euch unbeobachtet austauschen könnt. Der Ort muss frei von Stasi-Spitzeln sein und sollte unauffällig wirken. Achtet auf Ausgänge für eventuelle schnelle Fluchtwege. Wichtig ist auch, dass der Ort zu verschiedenen Tageszeiten aufgesucht werden kann. Jeder Beteiligte bringt wichtige Informationen mit, aber seid vorsichtig - Fehlinformationen können eure Pläne gefährden.',
    ),
    RoundObjective(
      roundNumber: 2,
      title: 'Dokumente fälschen',
      description: 'Ohne die richtigen Papiere kommt niemand weit. Ihr müsst Personalausweise, Passierscheine und Arbeitsbescheinigungen beschaffen oder fälschen. Die Dokumente müssen einer Kontrolle standhalten: Stempel, Unterschriften und Wasserzeichen müssen authentisch wirken. Der richtige Fälscher muss gefunden werden, und die nötigen Materialien müssen beschafft werden. Achtet auf neue Sicherheitsmerkmale, die kürzlich eingeführt wurden. Jede Unstimmigkeit in euren Dokumenten könnte auffallen und eure Identität verraten.',
    ),
    RoundObjective(
      roundNumber: 3,
      title: 'Fluchtroute planen',
      description: 'Die Berliner Mauer ist stark bewacht, aber es gibt Schwachstellen. Ihr müsst eine sichere Route finden, die an Wachtürmen, Patrouillen und Selbstschussanlagen vorbeiführt. Plant genau, wann und wo ihr die Grenze überqueren wollt. Beachtet auch die Schichtwechsel der Grenzsoldaten und kennt die Alarmierungssysteme. Überlegt auch, welche Ausrüstung ihr benötigt. Informationen über Tunnelbauprojekte oder bereits entdeckte Fluchtwege könnten hilfreich sein - aber seid vorsichtig, veraltete oder falsche Informationen könnten tödlich sein.',
    ),
    RoundObjective(
      roundNumber: 4,
      title: 'Kontakt im Westen herstellen',
      description: 'Für eine erfolgreiche Flucht braucht ihr Unterstützung auf der westlichen Seite. Jemand muss euch dort in Empfang nehmen und vorübergehend Unterschlupf gewähren. Dieser Kontakt muss absolut vertrauenswürdig sein und darf keine Verbindung zur Stasi haben. Vereinbart ein sicheres Kommunikationssystem und Erkennungszeichen. Plant auch, wie ihr nach erfolgreicher Flucht untertauchen könnt, bevor ihr neue Identitäten im Westen bekommt. Vertraut nicht blindlings - überprüft alle Informationen zu eurem Westkontakt sorgfältig.',
    ),
    RoundObjective(
      roundNumber: 5,
      title: 'Flucht durchführen',
      description: 'Der Tag der Flucht ist gekommen. Jetzt müssen alle Vorbereitungen zusammenkommen. Jeder muss seine Rolle kennen und exakt nach Plan handeln. Bereitet euch auf unvorhergesehene Ereignisse vor: Was tun bei verstärkten Kontrollen? Wie verhält man sich bei einer Befragung? Was ist der Notfallplan bei Entdeckung? Nehmt nur das Nötigste mit, um nicht aufzufallen. Vertraut auf eure Vorbereitung, aber seid bereit zu improvisieren. Eine letzte Überprüfung eurer Informationen ist entscheidend - ein einziger Fehler könnte alles zum Scheitern bringen.',
    ),
  ];
  
  final index = (round - 1) % objectives.length;
  return objectives[index];
}
}