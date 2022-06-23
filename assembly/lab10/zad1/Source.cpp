
#include <iostream>

using namespace std;

extern "C" {
	int __stdcall IncrementNumber(int number1, int number2, int number3);
	int __stdcall FillSpacebar(int tab[]);
}

int zm1, zm2, zm3, zm4;
int arr[4000];

int main()
{
	cout << "Wprowadz pierwsza liczbe: " << endl;
	cin >> zm1;
	cout << "Wprowadz druga liczbe: " << endl;
	cin >> zm2;
	cout << "Wprowadz trzecia liczbe: " << endl;
	cin >> zm3;
	//2*A - B - C
	
	zm1 = IncrementNumber(zm1, zm2, zm3);
	zm4 = FillSpacebar(arr);
	cout << "Liczba po zmianach to:" << zm1 << endl;
	cout << "tablica spacji to: " << zm4 << ", koniec " << endl;
	system("pause");
	return 0;
}