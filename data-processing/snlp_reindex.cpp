#include<iostream>
#include<fstream>
#include<string>
#include <sstream>
#include <boost/tokenizer.hpp>
#include <boost/foreach.hpp>
#include <map>

using namespace std;
using namespace boost;

string slurp(ifstream& in) {
  return static_cast<stringstream const&>(stringstream() << in.rdbuf()).str();
}

int main(int argc, char *argv[]) {
  map<string , long > indices;
  // load dictionary hash
  ifstream dictionary(argv[3]);
  string line;
  long index = 0;
  if (dictionary.is_open())
    {
      while ( dictionary.good() )
        {
          getline (dictionary,line);
          if( !line.compare("") == 0) {
            //cout << line << endl;
            index++;
            indices.insert(pair<string,long>(line,index));
          }
        }
      dictionary.close();
    }
  cout<<"INDEX:"<<index<<endl;
  // open output file
  ofstream outfile;
  outfile.open(argv[2],ios::out | ios::app);

  // write dictionary back to file
  ofstream dict2;
  dict2.open(argv[4],ios::out | ios::app);

  // initialize tokenizer
  typedef boost::tokenizer<boost::char_separator<char> > tokenizer;
  boost::char_separator<char> sep("-; |\n./,():\"");

  ifstream file_list(argv[1]);
  string filename;
  long old_index;
  if (file_list.is_open())
    {
      while ( file_list.good() )
        {
          getline (file_list,filename);
          if(!filename.compare("") == 0) {
            //----------"FOR EACH FILE"--------------------
            old_index = index;
            // open file
            ifstream inputfile (filename.c_str());
            // load file into a string
            string str = slurp(inputfile);
            tokenizer tokens(str, sep);

            // find word in dictionary, if not found, add it.
            map<string,long>::iterator it;
            BOOST_FOREACH(string t, tokens)
              {
                it = indices.find(t);
                if(it == indices.end()) {
                  //index++;
                  //indices.insert(pair<string,long>(t,index));
                  //it = indices.find(t);
                  it = indices.find("UNKNOWN");
                  dict2<<t<<endl;
                  // cout << t<< " INSERTED "<<it->first<<" "<<it->second  <<endl;
                  //cout << t<< " UNKNOWN"<<endl;
                }
                //else
                //  cout << t<< " "<<it->first<<" "<<it->second  <<endl;
                outfile << it->second << " ";
              }
            cout<<"total dictionary size:"<<index<<" "<<" words added:"
                <<index-old_index<<endl;
            outfile<<endl;
            //----------END OF "FOR EACH FILE"--------------------
          }
        }
      file_list.close();
    }

  dict2.close();
  outfile.close();
  map<string,long>::iterator it;
  it = indices.find("PADDING");
  cout <<it->first<<" "<<it->second  <<endl;

  return EXIT_SUCCESS;

}
