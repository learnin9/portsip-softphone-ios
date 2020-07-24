
#ifndef PORTSIP_MD5_hxx
#define PORTSIP_MD5_hxx

#include <string>

 class  MD5
  {
    public:
      /**
       * Constructs a new MD5 object.
       */
      MD5();

      /**
       * Virtual Destructor.
       */
      virtual ~MD5();

      /**
       * Use this function to feed the hash.
       * @param data The data to hash.
       * @param bytes The size of @c data in bytes.
       */
      void feed( const unsigned char* data, int bytes );

      /**
       * Use this function to feed the hash.
       * @param data The data to hash.
       */
      void feed( const std::string& data );

      /**
       * This function is used to finalize the hash operation. Use it after the last feed() and
       * before calling hex().
       */
      void finalize();

      /**
       * Use this function to retrieve the hash value in hex.
       * @return The hash in hex notation.
       */
      const std::string hex();

      /**
       * Use this function to retrieve the raw binary hash.
       * @return The raw binary hash.
       */
      const std::string binary();

      /**
       * Use this function to reset the hash.
       */
      void reset();

    private:
      struct MD5State
      {
          unsigned int count[2]; /* message length in bits, lsw first */
          unsigned int abcd[4]; /* digest buffer */
          unsigned char buf[64]; /* accumulate block */
      } m_state;

      void init();
      void process( const unsigned char* data );

      static const unsigned char pad[64];

      bool m_finished;

  };



#endif