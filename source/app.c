#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>

#include "PCIE.h"

//MAX BUFFER FOR DMA
#define MAXDMA 20

//BASE ADDRESS FOR CONTROL REGISTER
#define CRA 0x00000000

//BASE ADDRESS TO SDRAM
#define SDRAM 0x08000000

#define RWSIZE (32 / 8)

PCIE_BAR pcie_bars[] = { PCIE_BAR0, PCIE_BAR1 , PCIE_BAR2 , PCIE_BAR3 , PCIE_BAR4 , PCIE_BAR5 };

void test32( PCIE_HANDLE hPCIe, DWORD addr );
void testDMA( PCIE_HANDLE hPCIe, DWORD addr);
BOOL WriteStartByte(PCIE_HANDLE hPCIe);
BOOL WriteImage(PCIE_HANDLE hPCIe, char *filename);
BOOL checkImageDone(PCIE_HANDLE hPCIe);
BOOL clearMem(PCIE_HANDLE hPCIe);
void Demo(PCIE_HANDLE hPCIe, char *filename);

int main( int argc, char *argv[])
{
  if (argc != 2)
  {
    printf("Usage: ./ppm_reader <image_file>\n");
    return 0;
  }

	void *lib_handle;
	PCIE_HANDLE hPCIe;

	lib_handle = PCIE_Load();
	if (!lib_handle)
	{
		printf("PCIE_Load failed\n");
		return 0;
	}
	hPCIe = PCIE_Open(0,0,0);

	if (!hPCIe)
	{
		printf("PCIE_Open failed\n");
		return 0;
	}
  Demo(hPCIe, argv[1]);
	return 0;
}

// Main demo process
void Demo(PCIE_HANDLE hPCIe, char *filename)
{
	printf("\n\n");

	if(!WriteImage(hPCIe, filename)) // handles writing the image to SDRAM
		return;

	if(!WriteStartByte(hPCIe))  //writes the start byte to the csr_register[0]
        return;

	printf("\nProcessing finished.\n");
	printf("\n\n");
	return;
}

// Write STARTBYTE to slave register in user_module.sv
BOOL WriteStartByte(PCIE_HANDLE hPCIe)
{
	DWORD addr = 0x00000000;
	BYTE start = 0x01;   // Byte to write has start byte

	BOOL bPass = PCIE_Write32( hPCIe, pcie_bars[0], addr, start);
	if(!bPass)
	{
		printf("ERROR: unsuccessful start byte writing.\n");
		return FALSE;
	}
	else
		printf("Start byte written.\n");
	return TRUE;
}

// Write the image field to SDRAM
BOOL WriteImage(PCIE_HANDLE hPCIe,  char *filename)
{
  FILE *ppm_file = fopen(filename, "rb");   //opens the ppm_file for reading
  FILE *write_file = fopen("lion_read.ppm", "wb"); //opens the file to write the output too
  if (!ppm_file)
  {
    printf("Error, could not open ppm file for reading.");
    return FALSE;
  }
  char type[4]; //Includes ['P', '6', '\n', 'terminating character']
  if (!fgets(type, sizeof(type), ppm_file))
  {
    return FALSE;
  }
  if (strcmp(type, "P6\n") != 0)  //ppm file must be of the type P6
  {
    printf("Format must be P6!\n");
    return FALSE;
  }
  int width, height, num_colors;
  fscanf(ppm_file, "%d %d %d", &width, &height, &num_colors); //Extracts the width, height, number of colors from image
  fwrite(&type, sizeof(type), 1, write_file);
  fprintf(write_file, "%d %d\n%d\n", width, height, num_colors);

  while (fgetc(ppm_file) != '\n'); //ignore whitespace between header and actual image data
  unsigned char *ppm_image;   //buffer for ppm_image
  unsigned char *image_data_buffer;  //buffer for ppm_image when writing to SDRAM
  size_t image_size = width * height * 3 * sizeof(unsigned char);   //size for 24 bit/pixel image
  size_t image_data_buffer_size = width * height * 4 * sizeof(unsigned char);  //size for image with 32 bit SDRAM addresses
  // allocate size for ppm image and the buffer for storing in SDRAM
  ppm_image = (unsigned char*)malloc(image_size);
  image_data_buffer = (unsigned char*)malloc(image_data_buffer_size);
  fread(ppm_image, image_size, 1, ppm_file); // read the image data into the ppm_image_buffer
  int index = 0;
  int i = 0;
  int x = 0;
  while (i < width * height)
  {
    // 1 byte for R values
    image_data_buffer[index++] = ppm_image[x++];
    // 1 byte for G values
    image_data_buffer[index++] = ppm_image[x++];
    // 1 byte for B values
    image_data_buffer[index++] = ppm_image[x++];
    // 1 byte of 0 for padding, 32 bit SDRAM ADDRESS
    image_data_buffer[index++] = 0;
  }
  fwrite(image_data_buffer, image_data_buffer_size, 1, write_file); // write the image back to the output file

	//BYTE tempRGB;
	DWORD addr = 0x08000000;  //original image written starting from 0x08000000
	// Write only one pixel to the LSByte and zero pad the rest 24 bits

  BOOL bPass = PCIE_DmaWrite(hPCIe, addr, image_data_buffer, width*height*4);
	if(!bPass)
	{
		printf("ERROR: unsuccessful image writing.\n");
		return FALSE;
	}
	else
		printf("Image written.\n");
    

    
    unsigned char *testImage;
    testImage = malloc(image_data_buffer_size);
    
    BOOL zPass = PCIE_DmaRead(hPCIe, addr, testImage, width*height*4);
    if (!zPass)
    {
        printf("ERROR: unsuccessful image reading.\n");
        return FALSE;
    }
    else
    {
        printf("Image read by Atom.\n");
    }
	free(ppm_image);
	free(image_data_buffer);
	return TRUE;
}

// Check whether an image is finished by looking for STOPBYTE in slave register[0]
BOOL checkImageDone(PCIE_HANDLE hPCIe)
{
   BYTE b;
   DWORD addr = 0x00000000;
   BOOL bPass = PCIE_Read8( hPCIe, pcie_bars[0], addr, &b);
   BYTE check = 0x12;
   if(bPass)
   {
      if(b == check)
      {
      	//printf("Image done\n");
		return TRUE;
      }
      else
      {
      	//printf("Image not done yet\n");
      	return FALSE;
      }
   }
   return FALSE;
}

// Test whether PCIe is functional
void test32( PCIE_HANDLE hPCIe, DWORD addr )
{
	BOOL bPass;
	DWORD testVal = 0xf;
	DWORD readVal;

	WORD i = 0;
	for (i = 0; i < 16 ; i++ )
	{
		printf("Testing register %d at addr %x with value %x\n", i, addr, testVal);
		bPass = PCIE_Write32( hPCIe, pcie_bars[0], addr, testVal);
		if (!bPass)
		{
			printf("test FAILED: write did not return success\n");
			return;
		}
		bPass = PCIE_Read32( hPCIe, pcie_bars[0], addr, &readVal);
		if (!bPass)
		{
			printf("test FAILED: read did not return success\n");
			return;
		}
		if (testVal == readVal)
		{
			printf("Test PASSED: expected %x, received %x\n", testVal, readVal);
		}
		else
		{
			printf("Test FAILED: expected %x, received %x\n", testVal, readVal);
		}
		testVal = testVal + 1;
		addr = addr + 4;
	}
	return;
}

//tests DMA write of buffer to address
void testDMA( PCIE_HANDLE hPCIe, DWORD addr)
{
	BOOL bPass;
	DWORD testArray[MAXDMA];
	DWORD readArray[MAXDMA];

	WORD i = 0;

	while ( i < MAXDMA )
	{
		testArray[i] = i  + 0xfd;
		i++;
	}

	bPass = PCIE_DmaWrite(hPCIe, addr, testArray, MAXDMA * RWSIZE );
	if (!bPass)
	{
		printf("test FAILED: write did not return success");
		return;
	}
	bPass = PCIE_DmaRead(hPCIe, addr, readArray, MAXDMA * RWSIZE );
	if (!bPass)
	{
		printf("test FAILED: read did not return success");
		return;
	}
	i = 0;
	while ( i < MAXDMA )
	{
		if (testArray[i] == readArray[i])
		{
			//printf("Test PASSED: expected %x, received %x\n", testArray[i], readArray[i]);
		}
		else
		{
			printf("Test FAILED: expected %x, received %x\n", testArray[i], readArray[i]);
		}
		i++;
	}
	return;
}
