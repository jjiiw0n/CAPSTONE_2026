Program.cs: 메인 컨트롤러
LocalTagchecker.cs: 기존에 등록된 태그 ID 확인용
RegistrationManager.cs: 물품 등록 모드시 사용
FirebaseManager.cs: Firebase Firestore와의 통신
LcdManager.cs: LCD 화면 송출
ReaderMethod.cs, MessageTran.cs, ITalker.cs, Talker.cs: RFID 리더기 라이브러리
service-account.json: Firebase 보안 인증 키

LocalTagchecker
    Firebase의 데이터(태그 ID)를 실시간으로 동기화 
    calendar 컬렉션의 TagID 필드 값이 업데이트 되면 자동으로 로컬 DB(tags_db.json) 파일에 수정
    categories 컬렉션의 각 카테고리마다 존재하는 TagID 배열 값을 읽어와 파일에 수정
    Firebase에 있는 데이터가 삭제되면 tags_db.json 파일에서도 삭제
    카운트 기능으로 카운트가 0이 될 때 로컬 DB에서 삭제
    물품 등록 모드에서 감지된 태그가 신규 태그인지 판별할 때 사용


3/31
    Firebase의 system_control의 mode 필드를 register 또는 normal로 변경시 Program 파일에서도 자동으로 변경
    Program 파일에서 임의의 태그 ID 값을 생성하여 Firebase에 자동 업데이트 
    