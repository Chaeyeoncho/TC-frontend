import 'package:flutter/foundation.dart' show kIsWeb; // 플랫폼 확인을 위한 임포트
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Image Picker 패키지 임포트
import 'package:dotted_border/dotted_border.dart'; // Dotted Border 패키지 임포트
import 'dart:io';
import 'dart:typed_data'; // 이미지 데이터를 위한 패키지
import 'selectdate.dart'; // CustomDateRangeSelector 파일 임포트

class TravelDetailPage extends StatefulWidget {
  @override
  _TravelDetailPageState createState() => _TravelDetailPageState();
}

class _TravelDetailPageState extends State<TravelDetailPage> {
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가
  final TextEditingController _courseNameController =
      TextEditingController(); // 코스 이름 텍스트 컨트롤러

  List<File?> _selectedImages =
      List.generate(10, (_) => null); // 모바일에서 최대 10개의 이미지를 저장할 리스트
  List<Uint8List?> _webImages =
      List.generate(10, (_) => null); // 웹에서 최대 10개의 이미지를 저장할 리스트
  List<bool> _isLoading =
      List.generate(10, (_) => false); // 각 이미지의 로딩 상태를 저장할 리스트
  int _nextBoxToShow = 1; // 사용자가 사진을 입력하면 다음 박스를 표시할 변수
  int loadingTime = 3; // 로딩 시간을 3초로 설정

  List<DateTime>? _selectedDateRange; // 선택된 날짜 범위를 저장할 변수

  // 인덱스를 한글 숫자로 변환하는 함수
  String _getKoreanNumber(int index) {
    const koreanNumbers = [
      '첫',
      '두',
      '세',
      '네',
      '다섯',
      '여섯',
      '일곱',
      '여덟',
      '아홉',
      '열'
    ];
    return koreanNumbers[index];
  }

  Future<void> _pickImage(int index) async {
    final ImagePicker picker = ImagePicker();

    // 갤러리에서 이미지 선택
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isLoading[index] = true; // 해당 인덱스의 이미지 로딩 상태로 변경
      });

      // 비동기 작업을 진행하고 로딩 시간 동안 대기
      await Future.delayed(Duration(seconds: loadingTime)); // 3초 로딩 시간 대기

      if (kIsWeb) {
        // 웹의 경우
        Uint8List webImageBytes =
            await pickedFile.readAsBytes(); // 이미지를 Uint8List로 읽음
        setState(() {
          _webImages[index] = webImageBytes; // 해당 인덱스의 웹 이미지 저장
          _isLoading[index] = false; // 로딩 완료 상태로 변경
          if (index + 1 < 10) _nextBoxToShow = index + 2; // 다음 박스를 표시할 준비
        });
      } else {
        // 모바일(Android, iOS)의 경우
        setState(() {
          _selectedImages[index] = File(pickedFile.path); // 선택한 파일 경로에서 이미지 로드
          _isLoading[index] = false; // 로딩 완료 상태로 변경
          if (index + 1 < 10) _nextBoxToShow = index + 2; // 다음 박스를 표시할 준비
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages[index] = null;
      _webImages[index] = null;
      _isLoading[index] = false;
      _nextBoxToShow--; // 삭제 시 다음 박스를 표시할 변수 감소
    });
  }

  // 여행 날짜 선택 다이얼로그 표시 함수
  void _showDateSelectionDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white, // 다이얼로그 배경색을 흰색으로 설정
          child: Container(
            padding: EdgeInsets.all(10),
            child: CustomDateRangeSelector(
              onDateRangeSelected: (selectedDates) {
                // 날짜 선택 콜백 처리
              },
            ),
          ),
        );
      },
    );
  }

  // 날짜를 'yyyy/MM/dd' 형식으로 변환하는 함수
  String formatDateRange(List<DateTime> dateRange) {
    String format(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    return '${format(dateRange[0])} ~ ${format(dateRange[1])}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // 전체 패딩 추가
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 모든 요소를 왼쪽에 정렬
        children: <Widget>[
          SizedBox(height: 5), // Divider로부터 10만큼 간격 추가
          Row(
            children: [
              Expanded(
                // Expanded로 설정하여 가로 공간을 균등하게 나눔
                child: Container(
                  height: 30, // 박스의 높이
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(5),
                  ), // 회색 배경색
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '코스 이름:', // 박스 안의 텍스트
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _courseNameController,
                          decoration: InputDecoration(
                            border: InputBorder.none, // 텍스트 필드의 테두리를 제거
                            contentPadding: EdgeInsets.symmetric(horizontal: 5),
                            isDense: true, // 간격을 줄여서 정렬을 더 잘 맞추도록 함
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10), // 두 박스 간의 간격
              Expanded(
                child: GestureDetector(
                  onTap: _showDateSelectionDialog, // 클릭 시 다이얼로그 표시
                  child: Container(
                    height: 30, // 박스의 높이
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFEAEAEA),
                      borderRadius: BorderRadius.circular(5),
                    ), // 회색 배경색
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_selectedDateRange ==
                            null) // 선택된 날짜가 없을 경우에만 '여행 날짜' 텍스트 표시
                          Text(
                            '여행 날짜:', // 박스 안의 텍스트
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                        if (_selectedDateRange != null) // 선택된 날짜가 있을 경우 텍스트로 표시
                          Text(
                            ' ${formatDateRange(_selectedDateRange!)}', // 선택된 날짜 형식 변환
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5), // 회색 박스 밑에 10만큼 간격 추가
          Text('여행 사진 업로드 (최대 10장)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Container(
            height: 150, // 스크롤 영역의 높이 지정
            child: Scrollbar(
              controller: _scrollController, // 스크롤 컨트롤러 연결
              thumbVisibility: true, // 스크롤바 항상 표시
              child: SingleChildScrollView(
                controller: _scrollController, // 스크롤 컨트롤러 연결
                scrollDirection: Axis.horizontal, // 가로 스크롤 설정
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                  children: List.generate(
                      _nextBoxToShow,
                      (index) => _buildImageBox(
                          index)), // 사용자가 이미지를 추가한 개수만큼 박스를 동적으로 생성
                ),
              ),
            ),
          ),
          SizedBox(height: 10), // 스크롤 바와의 간격
          Divider(color: Color(0xFFE4E4E4), thickness: 1, height: 1),
        ],
      ),
    );
  }

  // 이미지 박스를 빌드하는 함수
  Widget _buildImageBox(int index) {
    bool hasImage = _selectedImages[index] != null || _webImages[index] != null;
    bool isLoading = _isLoading[index]; // 로딩 상태를 별도로 관리

    return Padding(
      padding: const EdgeInsets.only(right: 10.0), // 박스 간의 간격
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // 왼쪽 정렬
        children: [
          Text(
            '${_getKoreanNumber(index)} 번째 사진 기록', // 각 박스의 타이틀
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          SizedBox(height: 5), // 텍스트와 사진 박스 사이의 간격
          Stack(
            children: [
              isLoading
                  ? Container(
                      width: 145, // 박스의 너비
                      height: 120, // 박스의 높이
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0), // 텍스트의 좌우 여백 추가
                          child: Text(
                            'GPT-4 Vision으로 사진 분석 중...', // 로딩 중 텍스트 표시
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  : hasImage
                      ? Container(
                          width: 145, // 박스의 너비
                          height: 120, // 박스의 높이
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Center(
                            child: (_selectedImages[index] != null && !kIsWeb)
                                ? Image.file(
                                    _selectedImages[index]!,
                                    width: 120, // 이미지만의 너비
                                    height: 80, // 이미지만의 높이
                                    fit: BoxFit.contain, // 박스 크기에 맞게 이미지 조정
                                  )
                                : Image.memory(
                                    _webImages[index]!,
                                    width: 120, // 이미지만의 너비
                                    height: 80, // 이미지만의 높이
                                    fit: BoxFit.contain, // 박스 크기에 맞게 이미지 조정
                                  ),
                          ),
                        )
                      : DottedBorder(
                          // 이미지를 삽입하지 않은 박스는 점선 테두리
                          color: Colors.black, // 점선 색상
                          strokeWidth: 1, // 점선 두께
                          dashPattern: [4, 2], // 점선과 점선 사이의 간격 및 길이
                          borderType: BorderType.RRect, // 둥근 사각형 모양
                          radius: Radius.circular(10), // 둥근 모서리 반지름
                          child: Container(
                            width: 145, // 박스의 너비
                            height: 115, // 박스의 높이
                            color: Colors.white,
                            child: Center(
                              child: _buildAddButton(index),
                            ),
                          ),
                        ),
              if (hasImage)
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black, // 엑스표 아이콘 배경색
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // "사진 추가하기" 버튼을 빌드하는 함수
  Widget _buildAddButton(int index) {
    return TextButton(
      onPressed: () => _pickImage(index), // 버튼 클릭 시 파일 선택기 열기
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all<Color>(Color(0xFFE0E0E0)), // 회색 배경색 설정
        minimumSize: WidgetStateProperty.all<Size>(Size(85, 25)), // 버튼 크기 설정
      ),
      child: Text(
        '사진 추가하기',
        style: TextStyle(
          fontSize: 12,
          color: Colors.black, // 텍스트 색상 검정
          fontWeight: FontWeight.bold, // 텍스트 볼드체
        ),
      ),
    );
  }
}
