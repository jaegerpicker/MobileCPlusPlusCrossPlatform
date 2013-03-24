//
// Created by shawn on 3/23/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#include "mesh.h"
#ifdef __ANDROID__
#include <android/log.h>
#define  LOG_TAG    "libspinningcube"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#elif __WIN32
#define LOGI
#define LOGE
#elif __IPHONE_OS_VERSION_MIN_REQUIRED
#define LOGI
#define LOGE
#endif

cMesh::cMesh()
{
    m_numVertices = 0;
    m_pVertexPosition = NULL;
    m_pTriangleList = NULL;
    m_pVertexNormal = NULL;
    m_pVertexColor = NULL;
    m_pVertexTexCoord0 = NULL;

    m_numFaces = 0;
    m_pU16FacesList = NULL;
    m_pU32FacesList = NULL;
    m_face_type = 1;
    m_pNormalFaceList = NULL;

    m_vbo_position = 0;
    m_vbo_normal = 0;
    m_ibo = 0;
    m_update_vbo_position = 1;
    m_update_vbo_normal = 1;
    m_update_ibo = 1;

}


cMesh::~cMesh()
{
    freeMeshData();
}


void cMesh::freeMeshData()
{
    if(m_numVertices>0)
    {
        SAFE_DELETE_ARRAY(m_pVertexPosition);
        SAFE_DELETE_ARRAY(m_pVertexNormal);
        SAFE_DELETE_ARRAY(m_pVertexColor);
        SAFE_DELETE_ARRAY(m_pVertexTexCoord0);
        m_numVertices = 0;
    }

    if(m_numFaces>0)
    {
        SAFE_DELETE_ARRAY(m_pU16FacesList);
        SAFE_DELETE_ARRAY(m_pU32FacesList);
        SAFE_DELETE_ARRAY(m_pNormalFaceList);
        m_numFaces = 0;
    }
    if(m_numTriangles > 0)
    {
        SAFE_DELETE_ARRAY(m_pTriangleList);
    }
}


void cMesh::allocVertexData( unsigned long num_vertices )
{
    m_numVertices = num_vertices;

    m_pVertexPosition = new cVec4[num_vertices];
    m_pVertexNormal = new cVec4[num_vertices];
    //m_pVertexColor = new cVec4[num_vertices];
}


void cMesh::allocFaceData( int num_faces )
{
    m_numFaces = num_faces;
    //m_pNormalFaceList = new cVec4[num_faces];

    m_numTriangles = m_numFaces * 3;
    m_pTriangleList = new cVec4[m_numTriangles];
    m_pVertexColor = new cVec4[m_numTriangles];
    //m_pVertexTexCoord0 = new cVec4[m_numTriangles];
}

void cMesh::buildPlane( float width, float height, int wsegs, int hsegs )
{
    if( wsegs<1 ) wsegs=1;
    if( hsegs<1 ) hsegs=1;

    freeMeshData();

    allocVertexData( (wsegs+1)*(hsegs+1) );
    allocFaceData( 2*wsegs*hsegs );

    int v = 0;
    int x=0, y=0;
    int tu = 0;

    for( y=0; y<hsegs+1; y++ )
    {
        for( x=0; x<wsegs+1; x++ )
        {
            m_pVertexPosition[v].x = (float)x*(width/(float)wsegs);
            m_pVertexPosition[v].z = 0.0f;
            m_pVertexPosition[v].y = (float)y*(height/(float)hsegs);

            m_pVertexNormal[v].set(0.0, 1.0, 0.0, 0.0);

            //m_pVertexTexCoord0[v].x = x * (1.0f/wsegs);
            //m_pVertexTexCoord0[v].y = (hsegs-y) * (1.0f/hsegs);

            v++;
        }
    }


    int i=0, j=0, seg=0;

    for( y=0; y<hsegs; y++ )
    {
        for (int x=0; x<wsegs; x++)
        {
            i=6*(y*wsegs+x);
            j=y*(wsegs+1)+x;

            m_pTriangleList[seg*6] = m_pVertexPosition[j];
            m_pTriangleList[seg*6 + 1] = m_pVertexPosition[j+(wsegs+1)];
            m_pTriangleList[seg*6 + 2] = m_pVertexPosition[j+1];

            m_pTriangleList[seg*6 + 3] = m_pVertexPosition[j+1];
            m_pTriangleList[seg*6 + 4] = m_pVertexPosition[j+(wsegs+1)];
            m_pTriangleList[seg*6 + 5] = m_pVertexPosition[j+(wsegs+2)];

            seg++;
        }
    }

    setVerticesColor();
}

void cMesh::setVerticesColor()
{

    cVec4 colorA,colorB,colorC,colorD;
    colorA.set( 1.0,1.0,0.0,1.0 ); //yellow
    colorB.set( 0.0,1.0,1.0,1.0 ); //cyan
    colorC.set( 0.0,0.0,1.0,1.0 ); //blue
    colorD.set( 1.0,0.0,1.0,1.0 ); //magenta
    for( unsigned long i=0; i<m_numTriangles; i++ )
    {
        if(i%4 == 0) m_pVertexColor[i] = colorA;
        else if(i%4 == 0) m_pVertexColor[i] = colorB;
        else if(i%4 == 0) m_pVertexColor[i] = colorC;
        else m_pVertexColor[i] = colorD;
    }
}

void cMesh::computeVerticesNormals()
{
/*      if( m_numVertices==0 || !m_pNormalFaceList )
                return;


        int *sharedArray = new int[m_numVertices];

        unsigned long a, b, c;
        cVec4 side0, side1;
        cVec4 vNormal;
        unsigned long i, f;

        for( i=0; i<m_numVertices; i++ )
        {
                m_pVertexNormal[i].set( 0.0, 0.0, 0.0, 0.0 );
                sharedArray[i] = 0;
        }

        for( f=0; f<m_numFaces; f++ )
        {
                vNormal.set( 0.0, 0.0, 0.0, 0.0 );

                if( m_face_type==2 )
                {
                        a = m_pU32FacesList[f].a;
                        b = m_pU32FacesList[f].b;
                        c = m_pU32FacesList[f].c;
                }
                else
                {
                        a = m_pU16FacesList[f].a;
                        b = m_pU16FacesList[f].b;
                        c = m_pU16FacesList[f].c;
                }


                if( a>=0 && a<m_numVertices &&
                        b>=0 && b<m_numVertices &&
                        c>=0 && c<m_numVertices )
                {
                        side0 = m_pVertexPosition[a] - m_pVertexPosition[b];
                        side1 = m_pVertexPosition[c] - m_pVertexPosition[b];

                        vNormal = side1 ^ side0;
                        vNormal.normalize();

                        m_pNormalFaceList[f] = vNormal;

                        m_pVertexNormal[a] += vNormal;
                        sharedArray[a]++;

                        m_pVertexNormal[b] += vNormal;
                        sharedArray[b]++;

                        m_pVertexNormal[c] += vNormal;
                        sharedArray[c]++;
                }
        }

        for( i=0; i<m_numVertices; i++ )
        {
                m_pVertexNormal[i].scalarMult( 1.0f/(float)sharedArray[i] );
                m_pVertexNormal[i].w = 0.0;
                m_pVertexNormal[i].normalize();
        }

        SAFE_DELETE_ARRAY( sharedArray );*/
};

