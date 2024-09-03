#
# you will need to have the mpicc from you Open MPI build to be in your path
# to use this script.
#
export PYTHONPATH=$PYTHONPATH:$PWD/mpi4py/

#
# you only need to do these build steps if you make changes to Open MPI itself, otherwise if
# just making changes to PRRTE you can skip them
#

rm -rf mpi4py
git clone https://github.com/mpi4py/mpi4py.git
pushd mpi4py/
# git checkout 98174ae85f7ffaddf252b1e5343095208e29afd0
python3 setup.py build --mpicc="mpicc -shared"
python3 setup.py install --user
if [ $? -ne 0 ]
then
    echo "Something went wrong with MPI4PY build"
    exit -1
fi

pushd test
export OMPI_MCA_pml=ob1

echo "!!!!!!!!!!!!!!!!!!TESTING SINGLETON!!!!!!!!!!!!!!!!!!"
python3 ./main.py -v -f
if [ $? -ne 0 ]
then
    echo "Something went wrong with singleton"
    exit -1
fi
for nprocs in {1..5}
do
    mpirun -np $nprocs --map-by :OVERSUBSCRIBE python3 ./main.py -v -f
done 



