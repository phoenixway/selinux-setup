��|�         ��|�   SE Linux Module                   secure_app_user_home2   1.0@                                             file      getattr      execute_no_trans      relabelfrom	      relabelto      map      execute
      entrypoint                    chr_file      getattr      append      read      ioctl      write
                    filesystem	      associate                    capability2	      mac_admin                    process
      transition
                    capability      dac_override      dac_read_search                    dir      getattr      relabelfrom      search	      relabelto      open      read                object_r@           @           @                   @           
   
                   @           secure_app_t   
             @           secure_app_data_t                @           bin_t                @           user_home_t                @           user_devpts_t                @           secure_app_exec_t                @           user_home_dir_t                @           unconfined_t   	             @           fs_t                @           shell_exec_t                                                           @   @                 @               @   @                 @                               @   @          @       @               @   @                 @                               @   @          @       @               @   @                 @                              @   @          @       @               @           @                              @   @          @       @               @           @                               @   @          @       @               @   @                 @                               @   @          @       @               @   @                 @                               @   @          @       @               @   @                 @                     !          @   @          @       @               @   @          �       @                     !          @   @          @       @               @   @          �       @                               @   @                 @               @   @                 @                     =          @   @                 @               @   @                 @                     h          @   @                 @               @   @                  @                               @   @                 @               @   @          @       @                               @   @                 @               @   @          @       @                     b         @   @                 @               @           @                               @   @                 @               @   @                 @                                        @           @   @                 @           @   @          �      @           @           @           @              @   @                 @   @                 @   @          ?       @   @                 @   @                 @   @                 @   @                 @           @           @           @           @           @           @           @                                                                                         file            chr_file         
   filesystem            capability2            process         
   capability            dir               object_r         
      secure_app_t            secure_app_data_t            bin_t            user_home_t            user_devpts_t            secure_app_exec_t            user_home_dir_t            unconfined_t            fs_t            shell_exec_t                             