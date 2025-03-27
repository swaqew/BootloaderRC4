#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

uint8_t PRGA(uint8_t *i, uint8_t *j, uint8_t S[256]){
	uint8_t k;
	*i = (*i + 1) % 256;
	*j = (*j + S[*i])%256;
	uint8_t tmp = S[*i];
	S[*i] = S[*j];
	S[*j] = tmp;
	uint8_t t = (S[*i] + S[*j])%256;
	k = S[t]; 
	return k;	
}
void file_write(FILE *from_fd, FILE *to_fd, int i, uint8_t S[256]){
	if(i == 0){
		int c;
		while((c = fgetc(from_fd)) != EOF){
			fputc(c, to_fd);
		}
	}
	else{
		int c;
		uint8_t i = 0;
		uint8_t j = 0;
		while((c = fgetc(from_fd)) != EOF){
			uint8_t test = PRGA(&i, &j, S);
			fputc(c ^ test, to_fd);
		}
	}
}

void KSA(uint8_t S[256], uint8_t T[256], char key[8]){
	uint8_t k = 0;
	for(int i = 0; i < 256; i++){
		S[i] = k;
		T[i] = key[i%8];
		k++;
	}

	int j = 0;
	for(int i = 0; i < 256; i++){
		j = (j + S[i] + T[i])%256;
		uint8_t tmp = S[i];
		S[i] = S[j];
		S[j] = tmp;
	}
}

int main(){
	FILE *loader_fd = fopen("loader", "rb+");
	FILE *payload_fd = fopen("payload", "rb+");
	FILE *image_fd = fopen("image.bin", "wb+");
	
	uint8_t S[256];
	uint8_t T[256];
	char key[8];
	printf("Enter key: ");
	scanf("%8s", key);
	int l = strlen(key);
	if( l != 8){
		printf("Please enter keylen 8\n");
	}	
	KSA(S, T, key);

	file_write(loader_fd, image_fd, 0, S);
	file_write(payload_fd, image_fd, 1, S);	
		
	fclose(loader_fd);
	fclose(payload_fd);
	fclose(image_fd);
	return 0;
}	
