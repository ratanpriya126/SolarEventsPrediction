using Requests
using XMLconvert
using HTTP
using Colors
import Requests: get, post, put, delete, options,get_streaming
using JSON


function Load_data(start_time,end_time,N)
    max_row = 64
    max_col = 64

    h_matrix = Matrix(0,0)
    result_matrix = Matrix(0,0)
    wl_matrix = Matrix(0,0)
    current_time = start_time

    time_slot = ((end_time - start_time) / N)

    wavelength_array = [94 131 171 193 211 304 335 1600 1700]
    req_matrix = zeros(4,N)
    for m=1:N
        current_end_time = start_time+Dates.Millisecond(time_slot)
        url = "http://isd.dmlab.cs.gsu.edu/api/query/temporal?starttime="*string(start_time)*"&endtime="*string(current_end_time)*"&tablenames=ar,ch,sg&sortby=event_starttime&limit=100&offset=0&predicate=Overlaps"
        output = get(url)
        save(output,"test_"*string(m)*".json")
        dict4 = Dict()
        open("test_"*string(m)*".json","r") do f
            dicttxt = readstring(f)  # file information to string
            dict4=JSON.parse(dicttxt)
            event_type = dict4["Result"][1]["eventtype"]
            if event_type == "CH"
                event_idx = 1
            elseif event_type == "FL"
                event_idx = 2
            elseif event_type == "AR"
                event_idx = 3
            elseif event_type == "SG"
                event_idx = 4
            end
            req_matrix[event_idx,m] = 1
            start_time = current_end_time
            final_matrix = Matrix(0,0)

            for wl = 1:length(wavelength_array)
                wave = string(wavelength_array[wl])
                url = "http://dmlab.cs.gsu.edu/dmlabapi/params/SDO/AIA/64/full/?wave="*wave*"&starttime="*string(current_time)
                output = get(url)
                save(output,"x_"*string(m)*"_"*string(wl)*".xml")
                xdoc = parse_file("x_"*string(m)*"_"*string(wl)*".xml")
                xroot = root(xdoc)
                mdict = xml2dict(xroot)

                for i in 1:max_row
                    for j in 1:max_col
                        image_params = mdict["cell"][i]["params"][1]["param"]
                        if j == 1
                            h_matrix = image_params
                        else
                            h_matrix = hcat(h_matrix,image_params)
                        end
                    end
                    if i == 1
                        final_matrix = h_matrix
                    else
                        final_matrix = vcat(final_matrix,h_matrix)
                    end
                end
                final_matrix = reshape(final_matrix,640*64)
                if wl == 1
                    wl_matrix = final_matrix
                else
                    wl_matrix = vcat(wl_matrix,final_matrix)
                end
            end
            if m == 1
                println("IM HERE")
                result_matrix = wl_matrix
            else
                result_matrix = hcat(result_matrix,wl_matrix)
            end
            current_end_time = current_end_time+Dates.Millisecond(N)
        end
    end
    println(req_matrix) #Y
    size(result_matrix) #X
    writecsv("X.csv", req_matrix)
    writecsv("Y.csv", result_matrix)

    return result_matrix, req_matrix
end
